module LoadEdf

import EDFPlus
import JLD


const trodereplacements = Dict(
    "T3" => "T7",
    "T4" => "T8",
    "A1" => "T9",
    "A2" => "T10",
    "T1" => "F9",
    "T2" => "F10",
    "L-EKG" => "ECGL",
    "R-EKG" => "ECGR",
    "R-EYE" => "EOGR",
    "L-EYE" => "EOGL",
    "T5" => "P7",
    "T6" => "P8"
)


struct EEG
    signals :: Dict{String, Vector{Float64}}
    Fs :: Float64
    #annots :: Vector{EDFPlus.Annotation}
end #EEG struct


function fixname!(signame :: String)
    stripped = strip(signame)
    return get(trodereplacements, stripped, stripped)
end #fixname!


function loadEEG(filename :: String)
    edfh = EDFPlus.loadfile(filename)
    signals = Dict([fixname!(edfh.signalparam[i].label) => EDFPlus.physicalchanneldata(edfh,i) for i in 1:30])
    annots = edfh.annotations
    Fs = EDFPlus.samplerate(edfh, 2) # assumption that the sampling rate is the same on all channels; avoid channel 1 in case annotation
    myEEG = EEG(signals, Fs)
    EDFPlus.closefile!(edfh)
    return myEEG
end #loadEEG


function saveAsJLD(filename :: String, eeg :: EEG)
    JLD.save(filename, "eeg", eeg)
end #saveAsJLD


function convertDirectory!()
    Threads.@threads for ef in filter(x->splitext(x)[2] == ".edf", readdir())
        f,ext = splitext(ef)
        if isfile(f * ".jld")
            continue
        end #if

        println("Converting $ef...")
        saveAsJLD(f*".jld", loadEEG(ef))
        println("...converted $ef")

    end #for
end #convertDirectory!

end #module
