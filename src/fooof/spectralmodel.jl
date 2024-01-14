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
    apBounds = if apMode == "knee"
        apBounds
    else
        [bounds[1:2:end] for bound in apBounds]
    end

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


function simpleApFit(freqs, powerSpectrum)
    #todo    
end #func


function genAperiodic(freqs, apParams)
    #todo
end #func

function curveFit(apMode)
    #todo
end #func

