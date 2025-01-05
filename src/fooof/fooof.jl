#basic FOOOF
# 1. fit 1/f^b (or I ugess 1/(k+f^b))
# 2. fit Gaussian to peak of residuals
# 3. fit multiple Gaussians to peaks of residuals
# 4. when no peaks above 2*stdev stop
# 5. refit 1/f^b
# 6. add together Gaussians and 1/f^b
#
# think about how to fine-tune our guesses; massaging curve_fit seems to be the most difficult thing here
#

include("fooof/fitting.jl")

function cfit(model, data, Fs, p)
  ll = length(data)
  freq_mult = Fs/2 / ll
  LsqFit.curve_fit(model, range(1.0, step=freq_mult, length=ll), data, p)
end

function fitOOF(data :: Vector{Float64}, Fs :: Float64, offset0, expnt0, knee=false)
  if knee
    p = [offset expnt]
    fit = cfit(expoKneeFittingModel, data, Fs, p)
  else
    p = [offset expnt knee]
    fit = cfit(expoNoKneeFittingModel, data, Fs, p)
  end
  return fit
end

function fitGauss(data, Fs, μ0, wid0, ht0)
  p = [μ0 wid0 ht0]
  return cfit(gaussianFittingModel, data, Fs, p)
end

function fitMultiGauss(data, Fs, p)
  return cfit(multiGaussianFittingModel, data, Fs, p)
end

function findFWHM(index)
  #TODO
end

function estimateSD(fwhm)
  return fwhm/(2*√(2*log*2))
end

function findBiggestPeak(data :: Vector{Float64})
  inds, pks = findmaxima(data)
  biggestind = 0
  biggestpk = 0
  for i in 1:length(maxinds)
    if pks[i] > biggestpk
      biggestpk = pks[i]
      biggestind = inds[i]
    end
  end
  return biggestind, biggestpk
end

function aboveNoiseFloor(peak :: Float64, data :: Vector{Float64}, thresholdDev :: Float64)
  peak > thresholdDev*stdev(data)
end

"""the data is the raw EEG data; we will calculate the PSD explicitly"""
function FOOOF(data :: Vector{Float64}, Fs :: Float64)
  #setup
  threshold = 2
  psdData = log10(psd(data)) #log transformed PSD
  initOffset, initExpnt = 0 #need logic to make initial guesses
  
  
  #initial OOF fit
  if arbitrary_test() #how do we figure out whether to use a knee or not?
    initOOFFit = fitOOF(psdData, Fs, false)
  else
    initOOFFit = fitOOF(psdData, Fs, true)
  end
  offset, expnt = initOOFFit.param


  #iterate fitting Gaussians
  flag = false
  gaussians = []
  peakInd, peakAmp = findBiggestPeak(initGaussFit.residuals)
  if aboveNoiseFloor(peakAmp, data, threshold)
    flag = true
  end
  while flag
    flag = false
    #calculate widGuess from FWHM of peak
    findFWHM(peakInd)
    aGaussFit = fitGauss(initOOFFit.residuals, Fs, peakInd/Fs, widGuess, peakAmp)
    push!(gaussians, tuple(aGaussFit.param...)) #store params as vector of tuples
    peakInd, peakAmp = findBiggestPeak(aGaussFit.residuals)
    if aboveNoiseFloor(peakAmp, data, threshold)
      flag = true
    end
  end
  
  #now fit a multigaussian and 
  multiGaussFit = fitMultiGauss(initOOFFit.residuals, Fs, gaussians)
  
  #subtract multigaussians and do final OOF fit (does it need to have a knee?) using initial fit params as guesses
  newData = psdData .- multiGaussianFittingModel(range(1.0, step=Fs/(2*length(psdData), length=length(psdData))), multiGaussFit.param) #are the params a vector of tuples?
  finalFit = fitOOF(newData, Fs, offset, expnt, false)
  
  return newData .- expoNoKneeFittingModel(range(1.0, step=Fs/(2*length(psdData))), length=length(psdData), finalFit.param)
end #function FOOOF


