const avgTrodes = ["Fp1", "Fp2", "F7", "F8", "T7", "T8", "P7", "P8",
            "O1", "O2", "F3", "F4", "C3", "C4", "P3", "P4", "Fz", "Cz", "Pz"]

"creates a signal based on `eeg` which represents the average of the list `avgtrodes`"
function makeAvgRef(eeg :: EEG)
  ntrodes = length(avgTrodes)
  avgsig = zeros(eeg.length)
  sigs = zeros(eeg.length, ntrodes)
  for (j,trode) ∈ enumerate(global avgTrodes)
    sigs[:,j] = getSignal(eeg,trode)
  end #for
  for i in 1:eeg.length
    avgsig[i] = sum(sigs[i,:])/ntrodes
  end #for

  return avgsig
end #function

"re-references all the signals in `eeg` to the average"
function makeAvgRef!(eeg :: EEG)
  ntrodes = length(avgTrodes)
  avgRef = makeAvgRef(eeg)
  for t in avgTrodes
    ss = getSignal(eeg, t)
    ss = ss - avgRef
    putSignal!(eeg, t, ss)
  end #for
end #function

  
  
