module EEGFilter

using ..EEGStruct
using DSP

function prepareFilter(bpass, Fs, taps=64)
    l,h = bpass
    return remez(taps, [ (0,l) => 0.0, (l+0.05,h) => 1.0, (h+0.05, Fs/2) => 0.0 ] )
end

function dataFirFilter(data, bpass, Fs, taps=64)
    zpg = prepareFilter(bpass, Fs, taps)
    return filt(data, zpg)
end

function eegFirFilter!(eeg :: EEG, bpass, taps=64)
    for (trode, sig) in eeg.signals
        eeg.signals[trode] = dataFirFilter(sig, bpass, eeg.Fs, taps)
    end
end

function dataIirFilter(data, bpass, Fs, order=2)
    l,h = bpass
    zpg = analogfilter(Bandpass(l,h; Fs=Fs), Butterworth(order/2))
    return filt(data, zpg)
end

function eegIirFilter!(eeg :: EEG, bpass)
    for (trode, sig) in eeg.signals
        eeg.signals[trode] = dataIirFilter(sig, bpass, eeg.Fs)
    end
end


end #module
