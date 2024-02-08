function exportTSV(filename :: String, eeg :: EEG, signame1, signame2)
   sig1 = getSignal(eeg, signame1)
   sig2 = getSignal(eeg, signame2)
   f = open(filename, "w")
   for i in 1:eeg.length
     println(f, "$sig1[i] $sig2[i]")
   end #for
   close(f)
end #function

