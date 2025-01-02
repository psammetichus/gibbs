const avgTrodes = ["Fp1", "Fp2", "F7", "F8", "T7", "T8", "P7", "P8",
            "O1", "O2", "F3", "F4", "C3", "C4", "P3", "P4", "Fz", "Cz", "Pz"]

"creates a signal based on `eeg` which represents the average of the list `avgtrodes`"
function makeAvgRef(eeg :: EEG, trodes=avgTrodes)
  ntrodes = length(trodes)
  avgsig = zeros(eeg.length)
  sigs = zeros(eeg.length, ntrodes)
  for (j,trode) ∈ enumerate(trodes)
    sigs[:,j] = getSignal(eeg,trode)
  end #for
  for i in 1:eeg.length
    avgsig[i] = sum(sigs[i,:])/ntrodes
  end #for

  return avgsig
end #function

#assumes an array that's nsamples × ntrodes
function makeAvgRef(eeg :: Array{Float64})
  nsamples, ntrodes = length(eeg)
  avgsig = zeros(nsamples)
  for i in 1:nsamples
    avgsig[i] = sum(eeg[i,:])/ntrodes
  end #for
  return avgsig
end

"re-references all the signals in `eeg` to the average"
function makeAvgRef!(eeg :: EEG, trodes=avgTrodes)
  ntrodes = length(trodes)
  avgRef = makeAvgRef(eeg)
  for t in trodes
    ss = getSignal(eeg, t)
    ss = ss - avgRef
    putSignal!(eeg, t, ss)
  end #for
end #function

  
  
