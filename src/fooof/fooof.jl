struct FOOOF
    peakWidthLimits :: Tuple{Float64,Float64}
    maxNPeaks :: Union{Int,Nothing}
    minPeakHeight :: Float64
    peakThreshold :: Float64
    mode :: Symbol
    apPercentileThresh :: Float64
    apGuess
    apBounds
    bwStdEdge :: Float64
    gaussOverlapThresh :: Float64
    cfBound :: Float64
    maxFev :: Int
    errorMetric :: Symbol
end

struct FOOOFAttrs
    freqs :: Vector{Float64}
    powerSpectrum :: Vector{Float64} #log10 scale
    freqRange :: Vector{Tuple{Float64,Float64}}
    freqRes :: Float64
    fooofedSpectrum :: Vector{Float64}
    aperiodicParams :: Vector{Float64}
    peakParams :: 

function newFOOOF(  pkWidLim :: Tuple{Float64,Float64} = (0.5, 12.0),
                    maxNP :: Union{Int,Nothing} = nothing,
                    minPkHt :: Float64 = 0.0,
                    pkThresh :: Float64 = 2.0,
                    apMode :: Symbol = :fixed )

    return FOOOF(pkWidLim, maxNP, minPkHt, pkThresh, apMode,
                 0.025, (nothing,0,nothing), nothing, 1.0, 0.75,
                 1.5, 5000, :MAE)
end # func


                    
