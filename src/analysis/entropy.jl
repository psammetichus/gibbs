"""
calculates the permutation entropy of a signal

Segments of the signal are run through `findSymbol` to characterize
symbols based on the order of successive differences and then
calculating the entropy of the distribution of symbols
"""
function pentropy(arr :: Vector{Float64}) :: Float64
    perm, pnorm, cpe = PermEn(arr)
    return pnorm
end #function


"""calculates spectral entropy of a signal. Does not do windowing
or sfft"""
function spectralEntropy(signal :: Vector{Float64})
  spec, banden = SpecEn(signal)
  return spec
end #function


"""calculates wavelet entropy using Wavelets package"""
function waveletEntropy(signal :: Vector{Float64})
  coefentropy(signal, ShannonEntropy())
end

