module EEGJLD

export saveAsJLD, loadJLD
using ..EEGStruct

function saveAsJLD(filename :: String, eeg :: EEG)
    JLD.save(filename, "eeg", eeg)
end #saveAsJLD

function loadJLD(filename :: String)
    JLD.load(filename, "eeg")
end #loadJLD

end #module
