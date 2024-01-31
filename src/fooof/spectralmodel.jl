@enum ApMode apFixed apKnee

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
    apBounds = (apMode == apKnee) ? apBounds : [bounds[1:2:end] for bound in apBounds]

    apModel(x,p) = getApFunc(apMode)
    return curve_fit(model, freqs, powerSpectrum, guess)
end #func


function simpleApFit(freqs, powerSpectrum, apGuess, apBounds)

    #powerSpectrum is in log10 scale
    #get guess params or calc from data as needed

    offGuess = [powerSpectrum[1] if ! apGuess[1] else apGuess[1] end ]
    kneeGuess = ( apMode == apKnee) ? apGuess[2] : []
    expGuess = apGuess[3] ? 
                [ abs(powerSpectrum[end]) - abs(powerSpectrum[1]) /
                (log10(freqs[end]) - log10(freqs[1]))]
                : apGuess[3]
    apBounds = (apMode == apKnee) ? apBounds : [bounds[1:2:end] for bound in apBounds]
    
    guess = vcat(offGuess, kneeGuess, expGuess)
    
    #LsqFit
    apModel(x,p) = getApFunc(apMode)
    return curve_fit(model, freqs, powerSpectrum, guess)
    

end #func


function genAperiodic(freqs, apParams, apMode=nothing)
    if ! apMode
        inferApFunc(apParams)
    end #if

    apFunc = getApFunc(apMode)
    return apFunc(freqs, apParams...)  
end #func

function inferApFunc(apParams)
    if length(apParams) == 2
        return apFixed
    elseif length(apParams) == 3
        return apKnee
    end #if
end #func

function getApFunc(apMode)
    if apMode == apKnee
        return expoFittingFunc
    elseif apMode == apFixed
        return expoNoKneeFittingFunc
    end #if
end #func

