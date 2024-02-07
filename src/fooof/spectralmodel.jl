@enum ApMode apFixed apKnee

function fit(specModel, freqs, powerSpectrum, freqRange=nothing)

    #fit the aperiodic component
    aperiodicParams = robustApFit(freqs, powerSpectrum)
    apFit = genAperiodic(freqs, aperiodicParams)
    spectrumFlat = powerSpectrum - apFit
    gaussianParams = fitPeaks(spectrumFlat)


end #func


function robustApFit(fooof :: FOOOF)

    #initial simple fit
    popt = simpleApFit(fooof.attrs.freqs, fooof.attrs.powerSpectrum)
    initialFit = genAperiodic(fooof.attrs.freqs, popt)

    #flatten power spectrum based on initial aperiodic fit
    flatspec = fooof.attrs.powerSpectrum - initialFit

    #flatten outliers
    flatspec[flatspec .< 0] = 0

    #use percentile threshold
    pcntleThresh = percentile(flatspec, apPcntleThresh)
    pcntleMask = flatspec .≤ pcntleThresh
    freqsIgnore = fooof.attrs.freqs[pcntleMask]
    spectIgnore = fooof.attrs.powerSpectrum[pcntleMask]

    #get bounds for aperiodic fitting, dropping knee if not set to fit it
    #don't understand this
    apBounds = (apMode == apKnee) ? fooof.apBounds : [bounds[1:2:end] for bound in fooof.apBounds]

    apModel(x,p) = getApFunc(apMode)
    return curve_fit(apModel, fooof.attrs.freqs, fooof.attrs.powerSpectrum, guess)
end #func


function simpleApFit(fooof :: FOOOF, reqs)

    #powerSpectrum is in log10 scale
    #get guess params or calc from data as needed

    offGuess = [fooof.attrs.powerSpectrum[1] if ! fooof.apGuess[1] else fooof.apGuess[1] end ]
    kneeGuess = ( fooof.apMode == apKnee) ? fooof.apGuess[2] : []
    expGuess = fooof.apGuess[3] ? 
                [ abs(fooof.attrs.powerSpectrum[end]) - abs(fooof.attrs.powerSpectrum[1]) /
                (log10(fooof.attrs.freqs[end]) - log10(fooof.attrs.freqs[1]))]
                : fooof.apGuess[3]
    apBounds = (fooof.apMode == apKnee) ? fooof.apBounds : [bounds[1:2:end] for bound in fooof.apBounds]
    guess = vcat(offGuess, kneeGuess, expGuess)
    
    #LsqFit
    apModel(x,p) = getApFunc(apMode)
    return curve_fit(apModel, fooof.attrs.freqs, fooof.attrs.powerSpectrum, guess)
    

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

function getPEFunc(perMode)
    if peMode == "gaussian"
        return gaussianFittingFunc
    else
        @error "Periodic mode not understood"
    end #if
end #func

function fitPeaks(fooof :: FOOOF, flatIter)
    guess = zeros(0,3)
    while length(guess) < fooof.maxNPeaks
        maxInd = argmax(flatIter)
        maxHeight = flatIter[maxInd]

        if maxHeight <= fooof.peakThreshold * std(flatIter)
            break
        end #if

        guessFreq = fooof.freqs[maxInd]
        guessHeight = maxHeight
        if guessHeight > fooof.minPeakHeight
            break
        end #if

        halfHeight = 0.5 * maxHeight
        leInd = 
