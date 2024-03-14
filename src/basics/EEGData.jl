"contains information about study annotations"
struct Annotation 
  onset :: Float64
  duration :: Float64
  name :: String
  desc :: String
end #Annotation struct
  
"main struct of EEG data"
mutable struct EEG
  signals :: Array{Float64,2} #nsamples × mchans
  trodes :: Array{String} #m chans
  Fs :: Float64
  annots :: Vector{Annotation}
  length :: Int64
end #EEG struct

"constructor for `EEG`"
function EEG(signals, trodes, Fs, annots)
	EEG(signals, trodes, Fs, annots, size(signals)[1])
end #function 

"contains multiple segemnts of EEG data together with `offsets` in time between them"
mutable struct EegGroup
  eegs :: Vector{EEG}
  offsets :: Vector{Float64}
end #struct

"contains multiple `Annotation`s"
mutable struct AnnotationGroup
  onsets :: Vector{Float64}
  durations :: Vector{Float64}
  names :: Vector{String}
  descs :: Vector{String}
  len :: Int64
end

"adds an `Annotation` to an `AnnotationGroup`"
function addAnnotation!(ag :: AnnotationGroup, ann :: Annotation)
  push!(ag.onsets, ann.onset)
  push!(ag.durations, ann.duration)
  push!(ag.names, ann.name)
  push!(ag.descs, ann.desc)
end #func

"retrieve an annotation by index"
function getAnnotationByNum(ag :: AnnotationGroup, num :: Int64)
  return Annotation(ag.onsets[num], ag.durations[num], ag.names[num], ag.descs[num])
end #func

"find all annotations with the given `name`"
function findAnnotations(ag :: AnnotationGroup, name :: String)
  I = findall(x -> x == name, ag.names)
  anns = []
  for i in I
    push!(anns, getAnnotationByNum(ag, i))
  end #for
  return anns
end

"contains EEG data as a `DataFrame`"
struct EEGFrame
  signals :: DataFrame
  annots :: DataFrame
  length :: Int64
  Fs :: Float64
end

"converts a conventional `EEG` struct to a DataFrame-based one"
function convertToDataFrame(eeg :: EEG) :: EEGFrame
  ss = DataFrame(eeg.signals)
  aa = DataFrame(eeg.annots)
  EEGFrame(ss,aa,eeg.Fs)
end

"retrieves a signal, expressed as a vector of `Float64`, from two time periods (as seconds)"
function getSignal(eeg:: EEGFrame, fromTime :: Float64, toTime :: Float64)
  @assert f<t
  f, t = Int.(floor.((fromTime, toTime).*eeg.Fs))
  eeg.signals[f:t, :]
end #function

"contains info about an EEG subject"
mutable struct Subject
  id :: String
  age :: Int
  gender :: String
end

"get the channel number based on a an electrode name"
function findSignalChanNum(eeg :: EEG, trode :: String)
  for (i, name) in enumerate(eeg.trodes)
    if name == trode
      return i
    end #if
  end #for
  
  #default
  return nothing
end #function

"how many signals are in the `EEG` struct"
function signalCount(eeg :: EEG)
  return size(eeg.signals, 2)
end #function

"retrieves a signal, represented as a vector of `Float64`, based on an electrode name"
function getSignal(eeg :: EEG, trode :: String)
    i = findSignalChanNum(eeg, trode)
    if ! isnothing(i)
      return getSignal(eeg, i)
    else
      return nothing
    end #if
end #function

"retrieves a signal, represented as a vector of `Float64`, based on a channel number"
function getSignal(eeg :: EEG, chan :: Int64)
    return eeg.signals[:,chan]
end #function

"retrieves a signal that represents the difference of two signals chosen by name"
function getSignalDiff(eeg :: EEG, trodeOne :: String, trodeTwo :: String)
    chanOne = findSignalChanNum(eeg, trodeOne)
    chanTwo = findSignalChanNum(eeg, trodeTwo)
    return eeg.signals[:,chanOne] - eeg.signals[:, chanTwo]
end #function

"calculates a signal with an average reference"
function getSignalAvg(eeg :: EEG, trode :: String)
    avgR = makeAvgRef(eeg)
    sig = getSignal(eeg, trode)
    return sig - avgR
end

"calculates a signal with respect to a reference calculated by the function `refF`"
function getSignalRefF(eeg :: EEG, trode :: String, refF)
    sig = getSignal(eeg, trode)
    refSig = refF(eeg)
    return sig - refSig
end

"adds a signal to an `EEG` struct based on electrode name. It must be the same length as the other contained signals"
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

"adds a signal to an `EEG` struct based on channel number"
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

"filters the signals in `eeg` using the function `f`"
function filterSignal!(eeg :: EEG, selector :: String, f)
  s = getSignal(eeg, selector)
  putSignal!(eeg, selector, f(s))
end #function

"calculates a signal as a linear combination, expressed as a vector of weights, of each raw signal"
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


const freqBands = [ (α , [8.0, 13.0]), (β, [13.0, 35.0]), (δ, [1.0, 4.0]), (θ, [4.0, 8.0]) (γ, [35.0, 70.0])]

"returns the frequency band a given frequency is in, or `nothing`` if no matches"
function freqBand(freq :: Float64)
  for (band, lower, upper) in global freqBands
    if freq ≥ lower & freq < upper
      return band
    end #if
    #no match
    return nothing
  end #for
end #function

"""
calculates the frequencies corresponding to a series of `rfft`-based coefficients
and returns a dataframe
"""
function fourierFreqs(fourierCoeffs :: Vector{Float64}, Fs :: Float64)
  #assume from rfft, so all coeffs of positive freqs
  Nyq = Fs/2
  ll = div(length(fourierCoeffs),2)+1
  freqs = [i*(Nyq/ll) for i in 1:ll]
  return DataFrame(freqs = freqs, coeffs = fourierCoeffs)
end #function