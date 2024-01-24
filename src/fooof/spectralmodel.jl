using StatsBase


function fit(specModel, freqs, powerSpectrum, freqRange=nothing)

    #fit the aperiodic component
    aperiodicParams = robustApFit(freqs, powerSpectrum)
    apFit = genAperiodic(freqs, aperiodicParams)

end #func


function robustApFit(freqs, powerSpectrum, apPcntleThresh, apMode, apBounds)

    #initial simple fit
    popt = simpleApFit(freqs, powerSpectrum)
    initialFit = genAperiodic(freqs, popt)

    #flatten power spectrum based on initial aperiodic fit
    flatspec = powerSpectrum - initialFit

    #flatten outliers
    flatspec[flatspec .< 0] = 0

    #use percentile threshold
    pcntleThresh = percentile(flatspec, apPcntleThresh)
    pcntleMask = flatspec .≤ pcntleThresh
    freqsIgnore = freqs[pcntleMask]
    spectIgnore = powerSpectrum[pcntleMask]

    #get bounds for aperiodic fitting, dropping knee if not set to fit it
    #don't understand this
    apBounds = (apMode == "knee") ? apBounds : [bounds[1:2:end] for bound in apBounds]

    try
        apParams, _ = curveFit(
                               getApFunc(apMode),
                               freqsIgnore,
                               spectIgnore,
                               p0=popt,
                               maxFev,
                               bounds=apBounds,
                               ftol=tol,
                               xtol=tol,
                               gtol=tol,
                               checkFinite=false
                              )
    catch e
        #todo

    end #try

    return aperiodicParams
end #func


function simpleApFit(freqs, powerSpectrum, apGuess, apBounds)

    #powerSpectrum is in log10 scale
    #get guess params or calc from data as needed

    offGuess = [powerSpectrum[1] if ! apGuess[1] else apGuess[1] end ]
    kneeGuess = ( apMode == "knee" ) ? apGuess[2] : []
    expGuess = apGuess[3] ? 
                [ abs(powerSpectrum[end]) - abs(powerSpectrum[1]) /
                (log10(freqs[end]) - log10(freqs[1]))]
                : apGuess[3]
    apBounds = (apMode == "knee") ? apBounds : [bounds[1:2:end] for bound in apBounds]
    
    guess = vcat(offGuess, kneGuess, expGuess)
    
    try
        apParams, _ = curveFit(
                               getApFunc(apMode),
                               freqs,
                               powerSpectrum,
                               p0 = guess,
                               maxfev, bounds=apBounds,
                               ftol = tol,
                               xtol = tol,
                               gtol = tol,
                               checkFinite = false
                              )

    catch e

    end


end #func


function genAperiodic(freqs, apParams)
    #todo
end #func

function curveFit(apMode)
    #todo
end #func

