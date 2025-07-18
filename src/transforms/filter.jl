function prepareFilter(bpass :: Tuple{Float64, Float64}, Fs, taps=64)
    l,h = bpass
    return remez(taps, [ (0,l) => 0.0, (l+0.05,h-0.05) => 1.0, (h, Fs/2) => 0.0 ], Hz=Fs )
end

function eegFirFilter(data :: Array{Float64,1}, bpass, Fs, taps=64)
    coeffs = prepareFilter(bpass, Fs, taps)
    return filt(coeffs, data)
end

function eegFirFilter!(eeg :: EEG, bpass, taps=64)
    @threads for i in 1:signalCount(eeg)
        eeg.signals[:,i] = eegFirFilter(eeg.signals[:,i], bpass, eeg.Fs, taps)
    end
end

function eegIirFilter(data :: Array{Float64,1}, bpass, Fs, order=2)
    l,h = bpass
    zpg = digitalfilter(Bandpass(l,h; fs=Fs),Butterworth(div(order, 2)))
    return filt(zpg, data)
end

function eegIirFilter!(eeg :: EEG, bpass, order=2)
    @threads for i in 1:signalCount(eeg)
        eeg.signals[:,i] = eegIirFilter(eeg.signals[:,i], bpass, eeg.Fs, order)
    end
end

function notch(data :: Array{Float64,1}, Fs, freq=60.0)
    f = iirnotch(freq, 1.0; fs=512)
    return filt(f, data)
end #function

