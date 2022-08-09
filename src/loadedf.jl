module LoadEdf

import EDFPlus
import JD

function loadEEG(filename :: String)
    edfh = EDF.loadFile(filename)
    fixnames!(edfh)
    signals = Dict([fixname!(edfh.signalparam[i].label) => EDFPlus.physicalchanneldata(edfh,i) for i in 1:30])
    annots = edfh.annotations
    Fs = EDFPlus.samplerate(edfh, 2) # assumption that the sampling rate is the same on all channels; avoid channel 1 in case annotation
    myEEG = EEG(signals, Fs)
    EDFPlus.closefile!(edfh)
    return myEEG
end #loadEEG

const trodereplacements = Dict(
    "T3" => "T7"
    "T4" => "T8"
    "A1" => "T9"
    "A2" => "T10"
    "T1" => "F9"
    "T2" => "F10"
    "L-EKG" => "ECGL"
    "R-EKG" => "ECGR"
    "R-EYE" => "EOGR"
    "L-EYE" => "EOGL"
    "T5" => "P7"
    "T6" => "P8"
)


function fixname!(signame :: String)
    stripped = strip(signame)
    return get(trodereplacements, stripped, stripped)
end #fixname!

function saveAsJLD(filename :: String, eeg :: EEG)
    JLD.save(filename, "eeg", eeg)
end #saveAsJLD

struct EEG
    signals :: Dict{String, vector{Float64}}
    Fs :: Float64
    #annots :: Vector{EDFPlus.Annotation}
end #EEG struct


end #module