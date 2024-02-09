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

mutable struct EegGroup
  eegs :: Vector{EEG}
  offsets :: Vector{Float64}
end #struct

mutable struct AnnotationGroup
  onsets :: Vector{Float64}
  durations :: Vector{Float64}
  names :: Vector{String}
  descs :: Vector{String}
  len :: Int64
end

function addAnnotation!(ag :: AnnotationGroup, ann :: Annotation)
  push!(ag.onsets, ann.onset)
  push!(ag.durations, ann.duration)
  push!(ag.names, ann.name)
  push!(ag.descs, ann.desc)
end #func

function getAnnotationByNum(ag :: AnnotationGroup, num :: Int64)
  return Annotation(ag.onsets[num], ag.durations[num], ag.names[num], ag.descs[num])
end #func

function findAnnotations(ag :: AnnotationGroup, name :: String)
  I = findall(x -> x == name, ag.names)
  anns = []
  for i in I
    push!(anns, getAnnotationByNum(ag, i))
  end #for
  return anns
end

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

function getSignalDiff(eeg :: EEG, trodeOne :: String, trodeTwo :: String)
    chanOne = findSignalChanNum(eeg, trodeOne)
    chanTwo = findSignalChanNum(eeg, trodeTwo)
    return eeg.signals[:,chanOne] - eeg.signals[:, chanTwo]
end #function

function getSignalAvg(eeg :: EEG, trode :: String)
    avgR = makeAvgRef(eeg)
    sig = getSignal(eeg, trode)
    return sig - avgR
end

function getSignalRefF(eeg :: EEG, trode :: String, refF)
    sig = getSignal(eeg, trode)
    refSig = refF(eeg)
    return sig - refSig
end

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

function filterSignal!(eeg :: EEG, selector :: String, f)
  s = getSignal(eeg, selector)
  putSignal!(eeg, selector, f(s))
end #function

function linearComboSignal(eeg :: EEG, weights :: Vector{Float64})
  if length(weights) != signalCount(eeg)
    error("weights must equal signals")
  end #if

  res = zeros(eeg.length)

  for i ∈ 1:signalCount(eeg)
    if weights[i] == 0.0
      break #skip
    end #if
    res += weights[i] * getSignal(eeg, i)
  end #for
  return res
end #func

