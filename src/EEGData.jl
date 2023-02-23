struct Annotation 
  onset :: Float64
  duration :: Float64
  name :: String
  desc :: String
end #Annotation struct
  
struct EEG
  signals :: Dict{String, Signal}
  Fs :: Float64
  annots :: Vector{Annotation}
end #EEG struct

struct EEGFrame
  signals :: DataFrame
  annots :: DataFrame
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
