function saveAsJLD(filename :: String, eeg :: EEG)
    JLD.save(filename, "eeg", eeg)
end #saveAsJLD

function loadJLD(filename :: String)
    JLD.load(filename, "eeg")
end #loadJLD
