module Filtering

using DSP

function prepareFilter(bpass, taps=64, Fs)
    l,h = bpass
    return remez(taps, [ (0,l) => 0.0, (l+0.05,h) => 1.0, (h+0.05, Fs/2) => 0.0 ] )
end

function dataFirFilter(data, bpass, taps=64, Fs)
    zpg = prepareFilter(bpass, taps, Fs)
    return filt(data, zpg)
end

function eegFirFilter!(eeg :: EEG, bpass, taps=64)
    for trode, sig in eeg.signals
        eeg.signals[trode] = dataFirFilter(sig, bpass, taps, eeg.Fs)
    end
end

function dataIirFilter(data, bpass, order=2, Fs)
    l,h = bpass
    zpg = analogfilter(Bandpass(l,h; Fs=Fs), Butterworth(order/2))
    return filt(data, zpg)
end

function eegIirFilter!(eeg :: EEG, bpass)
    for trode, sig in eeg.signals
        eeg.signals[trode] = dataIirFilter(sig, bpass, eeg.Fs)
    end
end


end #module