"""
exports a pair of signals from `eeg` named by `signame` and `emgname` and
does so in a specific space-separated-value format accepted by the bacav codes
"""
function exportBacAv(filename :: String, eeg :: EEG, signame, emgname="EMG")
   eegsig = getSignalAvg(eeg, signame)
   emgsig = getSignalDiff(eeg, emgname*"1", emgname*"2")
   eegsig = eegFirFilter(eegsig, (1.0, 70.0), eeg.Fs)
   emgsig = eegFirFilter(emgsig, (10.0, 200.0), eeg.Fs)
   eegsig = notch(eegsig, eeg.Fs)
   emgsig = notch(emgsig, eeg.Fs)
   f = open(filename, "w")
   for i in 1:eeg.length
     s = eegsig[i]
     t = emgsig[i]
     println(f, "$s $t")
   end #for
   close(f)
end #function

