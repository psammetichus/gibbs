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

function findSignalChanNum(eeg :: EEG, trode :: String)
  for (i, name) in enumerate(eeg.trodes)
    if name == trode
      return i
    end #if
  end #for
  
  #default
  return nothing
end #function

function signalCount(eeg :: EEG)
  return size(eeg.signals, 2)
end #function

function getSignal(eeg :: EEG, trode :: String)
    i = findSignalChanNum(eeg, trode)
    if ! isnothing(i)
      return getSignal(eeg, i)
    else
      return nothing
    end #if
end #function

function getSignal(eeg :: EEG, chan :: Int64)
    return eeg.signals[:,chan]
end #function

function putSignal!(eeg :: EEG, trode :: String, newSignal)
    if length(newSignal) != eeg.length
      @error "Wrong length"
      return eeg
    end #if

    i = findSignalChanNum(eeg, trode)
    if !isnothing(i)
      putSignal!(eeg, i, newSignal)
      return eeg
    else
      return nothing
    end #if
end #function

function putSignal!(eeg :: EEG, chan :: Int64, newSignal :: Vector{Float64})
    if length(newSignal) != eeg.length
      @error "Wrong length"
      return eeg
    end #if

    if i > signalCount(eeg)
      @error "Out of bounds channel number"
      return eeg
    end #for

    eeg.signals[:,i] = newSignal 
    return eeg
end #function



