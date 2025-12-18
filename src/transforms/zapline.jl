#Zapline line noise cleaning algorithm based on https://github.com/MariusKlug/zapline-plus and the following papers:

#Klug, M., & Kloosterman, N. A. (2022).Zapline-plus: A Zapline extension for automatic and adaptive removal of frequency-specific noise artifacts in M/EEG.
#Human Brain Mapping,1–16. https://doi.org/10.1002/hbm.25832

#de Cheveigne, A. (2020) ZapLine: a simple and effective method to remove power line artifacts.
#NeuroImage, 1, 1-13. https://doi.org/10.1016/j.neuroimage.2019.116356

#And the zapline matlab algorithm found at http://audition.ens.fr/adc/NoiseTools/src/NoiseTools/doc/NoiseTools/nt_zapline.html
#NoiseTools is not well-commented. It appears they expect data matrix as time x channels or time x channels x trials




function zaplineCleanData(data, Fs, fline, nremove; kwargs...)
    #fline is normalized to Fs
    #warn that high sampling rates can affect results
    if Fs > 500
        @warn "It is recommended to downsample to 250–500 Hz or results may be suboptimal."
    end

    
    nkeep = getkey(kwargs, :nkeep, size(data,2))
    nfft = getkey(kwargs, :nfft, 512)
    nIters = getkey(kwargs, :niters, 1)
       
    #convolve with square window
    xx = zaplineSmoothe(x,1/fline,nIters) #cancels line freq and harmonics, light lowpass
    xxxx = zaplinePCA(x - xx, [], nkeep)
    

end #function zaplineCleanData

function zaplinePCA(x, shifts=[0], nkeep=[], threshold=[], w=[])
    m,n = size(x)
    o = 1

    offset = max(0, -min(shifts))
    shifts += offset                 # adjust shifts to make them nonnegative
    idx = offset + (1:m-max(shifts)) # x[idx] maps to z
    c = zaplineCov(x,shifts,w)
    #TODO FINISH

end #function zaplinePCA

function zaplineCov(x, shifts, w) #for 2D matrices x
    nshifts = prod(size(shifts))
    xSizes = size(x)
    xDim = length(xSizes)
    c = zeros(xSizes[2]*nshifts)
    if isempty(w)
        xx = zaplineMultishift(x, shifts)
        c = c + xx' * xx
        tw = size(xx,1)
        return c, tw
    else
        #TODO

    end #if
end #function zaplineCov

function zaplineMultishift(x, shifts)
end

function zaplineSmoothe(x, T, nIters=1, noDelayFlag=false)
    integ = floor(T)
    frac = T - integ

    if integ > size(x, 1)
        x = repeat(mean(x), size(x,1), 1, 1, 1)
        return x
    end

    #remove onset step
    mn = mean(x[1:integ+1,:,:],1)
    x = x - mn

    if nIters == 1 && frac == 0
        #faster
        x = cumsum(x)
        x[T+1:end,:] = x[T+1:end,:] - x[1:end-T,:]
        x = x/T
    else
        #filter kernel
        scaledOnes = [ones(integ,1); frac]/T
        B = scaledOnes
        for k ∈ 1:nIters-1
            B = conv(B, scaledOnes)
        end
        x = filt(B[:,1],1,x)
    end
    
    if noDelayFlag
        shift = round(T/2*nIters)
        x = [x[shift+1:end,:,:,:]; zeros(shift,size(x,2),size(x,3),size(x,4))]
    end

    #restore DC
    x = x + mn
    return x
end