const RMat = Array{Float64,2}

#basic FOOOF
# 1. fit 1/f^b (or I ugess 1/(k+f^b))
# 2. fit Gaussian to peak of residuals
# 3. fit multiple Gaussians to peaks of residuals
# 4. when no peaks above 2*stdev stop
# 5. refit 1/f^b
# 6. add together Gaussians and 1/f^b
#
# think about how to fine-tune our guesses
#


function fitOOF(data :: Vector{Float64}, Fs :: Float64)
  offset = 20.0
  expnt = -1.5
  p = [offset expnt]
  fit = LsqFit.curve_fit(expoFittingModel, range(1.0, step=1.0/Fs, length=length(data)), data, p)
  return fit
end

function fitGauss(data, Fs, μ0, wid0, ht0)
  p = [μ0 wid0 ht0]
  fit = LsqFit.curve_fit(gaussianFittingModel, range(1.0, step=1.0/Fs, length=length(data)), data, p)
end

function fitMultiGauss(data, Fs, μs, widths, heights)
  ll = length(data)

  for i in μs
    #TODO actually construct the model    
  end
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
  threshold = 2
  psdData = psd(data)
  initOffset, initExpnt
  initOOFFit = fitOOF(psdData, Fs)
  offset, expnt = initOOFFit.param

  flag = false
  gaussians = []
  peakInd, peakAmp = findBiggestPeak(initGaussFit.residuals,threshold)
  if aboveNoiseFloor(peakAmp)
    flag = true
  end
  while flag
    flag = false
    #calculate widGuess from FWHM of peak
    aGaussFit = fitGauss(initOOFFit.residuals, Fs, peakInd/Fs, widGuess, peakAmp)
    gaussians = hcat(gaussians, aGaussFit.param) #doesn't work with gaussians = []
    peakInd, peakAmp = findBiggestPeak(aGaussFit.residuals, threshold)
    if aboveNoiseFloor(peakAmp)
      flag = true
    end
  end
  
  multiGaussFit = fitMultiGauss(initOOFFit.residuals, Fs, gaussians[1,:], gaussians[2,:], gaussians[3,:])
  
end


