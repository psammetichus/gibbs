function exportBacAv(filename :: String, eeg :: EEG, signame, emgname="EMG")
   eegsig = getSignalAvg(eeg, signame)
   emgsig = getSignalDiff(eeg, emgname*"1", emgname*"2")
   f = open(filename, "w")
   for i in 1:eeg.length
     s = eegsig[i]
     t = emgsig[i]
     println(f, "$s $t")
   end #for
   close(f)
end #function

