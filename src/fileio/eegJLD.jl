function saveAsJLD(filename :: String, eeg :: EEG)
    JLD.save(filename, "eeg", eeg)
end #saveAsJLD
