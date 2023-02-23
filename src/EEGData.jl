struct Annotation 
  onset :: Float64
  duration :: Float64
  name :: String
  desc :: String
end #Annotation struct
  
struct EEG
  signals :: Dict{String, Vector{Float64}}
  Fs :: Float64
  annots :: Vector{Annotation}
end #EEG struct

function signalDataFrame(eeg :: EEG)
  DataFrame(eeg.signals)
end

function getSignal(fromTime :: Float64, toTime :: Float64)
  
end #function
