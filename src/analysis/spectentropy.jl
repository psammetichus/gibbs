"""calculates spectral entropy of a signal. Does not do windowing
or sfft"""
function spectralEntropy(signal :: Vector{Float64})
  psd = abs.(rfft(signal)).^2
  psd = psd ./ sum(psd)
  entropy = 0.0
  for ω in psd
    entropy += -ω * log2(ω)
  end #for
  return entropy
end #function
