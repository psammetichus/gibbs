module EEGStruct

export Annotation, EEG, EEGFrame, convertToDataFrame, getSignal
using DataFrames
using ..Basics
using ..Trodes


struct Annotation 
  onset :: Float64
  duration :: Float64
  name :: String
  desc :: String
end #Annotation struct
  
mutable struct EEG
  signals :: Array{Float64,2} #nsamples × mchans
  trodes :: Array{String} #m chans
  Fs :: Float64
  annots :: Vector{Annotation}
  length :: Int64
end #EEG struct

function EEG(signals, trodes, Fs, annots)
	EEG(signals, trodes, Fs, annots, size(signals)[1])
end #function 


struct EEGFrame
  signals :: DataFrame
  annots :: DataFrame
  length :: Int64
  Fs :: Float64
end

function convertToDataFrame(eeg :: EEG) :: EEGFrame
  ss = DataFrame(eeg.signals)
  aa = DataFrame(eeg.annots)
  EEGFrame(ss,aa,eeg.Fs)
end

function getSignal(eeg:: EEGFrame, fromTime :: Float64, toTime :: Float64)
  @assert f<t
  f, t = Int.(floor.((fromTime, toTime).*eeg.Fs))
  eeg.signals[f:t, :]
end #function

mutable struct Subject
  id :: String
  age :: Int
  gender :: String
end

function getSignal(eeg :: EEG, trode :: String)
    for (i, name) in enumerate(trodes)
        if name == trode
            return i
        else
            return nothing
        end #if
    end #for
end #function

function getSignal(eeg :: EEG, chan :: Int64)
    return eeg.signals[:,chan]
end #function

end #module
