const RMat = Array{Float64,2}

#basic FOOOF
# 1. fit 1/f^b
# 2. fit Gaussian to peak of residuals
# 3. fit multiple Gaussians to peaks of residuals
# 4. when no peaks above 2*stdev stop
# 5. refit 1/f^b
# 6. add together Gaussians and 1/f^b

function fitOOF(data :: Vector{Float64}, Fs :: Float64)
  fit = LsqFit.curve_fit(expoNoKneeFittingModel, range(1.0, step=1.0/Fs, length=length(data)), data, [20.0, -1.5])
  return fit
end

function fitGauss(data, Fs)

end

function FOOOF(data :: Vector{Float64}, Fs :: Float64)
  initOOFFit = fitOOF(data, Fs)
  offset, expnt = initOOFFit.param
  r = initOOFFit.residuals

  initGaussFit = fitGauss(data, Fs)
end



mutable struct FOOOF
    peakWidthLimits :: Tuple{Float64,Float64}
    maxNPeaks :: Union{Int,Nothing}
    minPeakHeight :: Float64
    peakThreshold :: Float64
    mode :: Symbol
    apPercentileThresh :: Float64
    apGuess :: Tuple{Float64,Float64,Float64}
    apBounds 
    bwStdEdge :: Float64
    gaussOverlapThresh :: Float64
    gaussStdLimits :: Tuple{Float64,Float64}
    cfBound :: Float64
    maxFev :: Int
    errorMetric :: Symbol
    debug :: Bool
    checkData :: Bool
    attrs :: Union{FOOOFAttrs,Nothing}
end

mutable struct FOOOFAttrs
    freqs :: Vector{Float64}
    powerSpectrum :: Vector{Float64} #log10 scale
    freqRange :: Tuple{Float64,Float64}
    freqRes :: Float64
    fooofedSpectrum :: Vector{Float64}
    aperiodicParams :: Vector{Float64}
    peakParams :: RMat
    gaussianParams :: RMat
end

struct FOOOFFreqs
    freqs :: Vector{Float64}
    freqRange :: Tuple{Float64,Float64}
    freqRes :: Float64
end

mutable struct FOOOFResults
    fooofedSpectrum :: Vector{Float64}
    aperiodicParams :: Vector{Float64}
    peakParams :: RMat
    gaussianParams :: RMat
    rSquared :: Float64
    error :: Float64
    spectrumFlat :: Vector{Float64}
    spectrumPeakRm :: Vector{Float64}
    apFit :: Vector{Float64}
    peakFit :: Vector{Float64}
end

 

function newFOOOF(  pkWidLim :: Tuple{Float64,Float64} = (0.5, 12.0),
                    maxNP :: Union{Int,Nothing} = nothing,
                    minPkHt :: Float64 = 0.0,
                    pkThresh :: Float64 = 2.0,
                    apMode :: Symbol = :fixed )

    return FOOOF(pkWidLim, maxNP, minPkHt, pkThresh, apMode,
                 0.025, (nothing,0,nothing), nothing, 1.0, 0.75, [],
                 1.5, 5000, :MAE, false, false, nothing)
end # func


function hasData(f :: FOOOF) :: Bool
  if isnothing(f.attrs)
    return false
  else
    if isempty(f.attrs.powerSpectrum)
      return false
    else
      return true
    end
  end
end #hasData

function hasModel(f :: FOOOF) :: Bool
  if isnothing(f.attrs)
    return false
  elseif all(isnan, f.attrs.aperiodicParams)
    return false
  else
    return true
  end
end #hasModel

function nPeaks(f :: FOOOF) :: Union{RMat, Nothing}
  if hasModel(f)
    return f.attrs.peakParams
  else
    return nothing
  end
end #nPeaks

function resetInternalSettings(f :: FOOOF)
  f.gaussStdLimits = (x -> x/2).(f.peakWidthLimits)
end #resetInternalSettings

function resetDataResults(f::FOOOF)
# just going to set attrs to nothing
# the python code can reset either the freqs, the spectrum, or the results
# and this is great but it means all sorts of stupid sentinel checking
# could refactor attrs into these three types
end #func
