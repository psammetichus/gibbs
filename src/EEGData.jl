struct Annotation 
  onset :: Float64
  duration :: Float64
  name :: String
  desc :: String
end #Annotation struct
  
mutable struct EEG
  signals :: Array{Signal,2} #nsamples × mchans
  trodes :: Array{String} #m chans
  Fs :: Float64
  annots :: Vector{Annotation}
  procSignals :: Dict{String, Signal}
  length :: Int64
end #EEG struct

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
end #function