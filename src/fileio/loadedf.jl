import EDFPlus
import JLD
using Logging

const trodereplacements = Dict(
    "T3" => "T7",
    "T4" => "T8",
    "A1" => "T9",
    "A2" => "T10",
    "T1" => "F9",
    "T2" => "F10",
    "L EKG" => "ECGL",
    "R EKG" => "ECGR",
    "R-EYE" => "EOGR",
    "L-EYE" => "EOGL",
    "L EKG" => "ECGL",
    "R EKG" => "ECGR",
    "T5" => "P7",
    "T6" => "P8"
)



function fixname!(signame :: String)
    stripped = strip(signame)
    return get(trodereplacements, stripped, stripped)
end #fixname!


function loadEEGFromEDF(filename :: String)
    edfh = EDFPlus.loadfile(filename)
    signals = Dict([fixname!(edfh.signalparam[i].label) => EDFPlus.physicalchanneldata(edfh,i) for i in 1:30])
    rawAnnots = append!(edfh.annotations...)
    annots = [Annotation(ann.onset, 0.0, ann.annotation[1], ann.annotation[2]) for ann in rawAnnots]
    Fs = EDFPlus.samplerate(edfh, 2) # assumption that the sampling rate is the same on all channels; avoid channel 1 in case annotation
    myEEG = EEG(signals, Fs, annots)
    EDFPlus.closefile!(edfh)
    return myEEG
end #loadEEG


function convertDirectory!()
    Threads.@threads for ef in filter(x->splitext(x)[2] == ".edf", readdir())
        f,ext = splitext(ef)
        if isfile(f * ".jld")
            continue
        end #if

        @info "Converting $ef..."
        saveAsJLD(f*".jld", loadEEG(ef))
        @info "...converted $ef"

    end #for
end #convertDirectory!
