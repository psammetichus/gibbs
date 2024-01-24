module EEGIO

import EDFPlus
import JLD
using Logging
using ..EEGStruct

export loadEEGFromEDF, loadEEGFromJLD, convertDirectory!

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


# only adds first 30 channels; need to fix

function loadEEGFromEDF(filename :: String)
    edfh = EDFPlus.loadfile(filename)
    nchans = edfh.channelcount
    signalchannels = []
	names = []
	for (i, chan) in enumerate(edfh.signalparam)
		if !chan.annotation   
			push!(signalchannels, i)
			push!(names, fixname!(edfh.signalparam[i].label))
		end #if
	end #for
    signals = hcat( [EDFPlus.physicalchanneldata(edfh,i) 
			for i in signalchannels] )
    rawAnnots = append!(edfh.annotations...)
    annots = [Annotation(ann.onset, 0.0, ann.annotation[1], ann.annotation[2]) for ann in rawAnnots]
    Fs = EDFPlus.samplerate(edfh, signalchannels[1]) 
	l = size(signals, 1)
    myEEG = EEG(signals, names, Fs, annots, l)
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

function loadEEGfromJLD(filename :: String)
    f = JLD.loadfile(filename)
    close(f)
end

end #convertDirectory!

end #module
