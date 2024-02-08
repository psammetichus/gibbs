function exportTSV(filename :: String, eeg :: EEG, signame1, signame2)
   sig1 = getSignal(eeg, signame1)
   sig2 = getSignal(eeg, signame2)
   f = open(filename, "w")
   for i in 1:eeg.length
     s = sig1[i]
     t = sig2[i]
     println(f, "$s $t")
   end #for
   close(f)
end #function

