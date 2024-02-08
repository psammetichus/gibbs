function makeAvgRef(eeg)
  trodes = ["Fp1", "Fp2", "F7", "F8", "T7", "T8", "P7", "P8",
            "O1", "O2", "F3", "F4", "C3", "C4", "P3", "P4"]
  ntrodes = length(trodes)
  try
    avgsig = zeros(eeg.length)
    sigs = hcat([getSignal[t] for t in trodes])
    for i in 1:eeg.length
      avgsig[i] = sum(sigs[i,:])/ntrodes
    end #for
  catch e
    #todo
  end #try

  return avgsig
end #function

function makeAvgRef!(eeg)
  trodes = ["Fp1", "Fp2", "F7", "F8", "T7", "T8", "P7", "P8",
            "O1", "O2", "F3", "F4", "C3", "C4", "P3", "P4"]
  ntrodes = length(trodes)
  avgRef = makeAvgRef(eeg)
  for t in trodes
    ss = getSignal(eeg, t)
    ss = ss - avgRef
    putSignal!(eeg, t)
  end #for
end #function

  
  
