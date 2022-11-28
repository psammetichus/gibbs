module BIS

#a module for calculating the bispectral index of an EEG (or other signal,
#frankly) based on the reverse-engineered algorithm presented by
#DOI:10.1038/s41598-019-50391-x 

using DSP
using FFTW
using Basics

function linearbis(which :: Symbol, bsrCoeff, sefCoeff, rbrCoeff, emgCoeff)
    if which == :green
        -0.42bsrCoeff + 42.1
    end 
    if which == :orange
        -0.42bsrCoeff + 0.91sefCoeff + 3.06rbrCoeff + 0.04emgCoeff + 29.9
    end
    if which == :green
        -3.01bsrCoeff + 3.84sefCoeff - 8.70rbrCoeff + 0.96emgCoeff - 57.6
    end
    if which == :blue
        -1.43bsrCoeff + 2.55sefCoeff + 4.26rbrCoeff + 0.41emgCoeff + 5.3
    end
    if which == :purple
        -1.97bsrCoeff + 0.88sefCoeff + 7.89rbrCoeff - 0.07emgCoeff + 65.2
    end
end


function getAround(i, sig, width)
    ll = length(sig)
    w = div(width/2)
    if i - w < 0
        [repeat([0.0], -(i - w)+1); sig[1:i+w]]
    elseif i + w > ll
        [sig[i-w:ll]; repeat([0.0], i+w-ll)] 
    else
        sig[i-w:i+w]
    end
end #getAround


function bsr(sig :: Signal, width :: Int64)
    ll = length(sig)
    output = zeros(ll)
    Threads.@threads for i in 1:ll
        seg = getAround(i, sig, width)
        output[i] = length(filter(x->abs(x)<5.0, seg))/ll
    end #for
end #function bsr

function bispectrum(sig :: Signal, Fs :: Int64, f1 :: Float64, f2 :: Float64) :: Float64
    ll = length(sig)
    Xsig = fft(sig)
    f1p, f2p, f12p = cycphsamp.((f1,f2,f1+f2))
    freqs = fftfreqs(ll, Fs)
    f1q, f2q, f12q = [findfirst(x->x>f,Xsig)-1 for x in (f1p,f2p,f12p)]
    return abs(sum(Xsig[[f1q,f2q,f12q]]))
end #bispectrum

function bis(sig :: Signal)
    BSR = bsr(sig)
    if BSR > 0.498
        return linearbis(:green, BSR, 0.0, 0.0, 0.0)
    end
    
    EMG = emg(sig)
    SEF = sef(sig)
    RBR = rbr(sig)
    if EMG < 34.2 && SEF < 20.2
        if BSR > 0.021 || SEF < 14.8
            return linearbis(:orange, BSR, SEF, RBR, EMG)
        else
            return linearbis(:green, BSR, SEF, RBR, EMG)
        end
    else
        if RBR < -0.7
            return linearbis(:blue, BSR, SEF, RBR, EMG)
        else
            return linearbis(:purple, BSR, SEF, RBR, EMG)
        end
    end
end #function bis



end #BIS
