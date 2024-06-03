function findSymbol(arr :: Vector{Float64}) :: UInt32
    n = length(arr)
    sentinel = true
    symbol = 0
    while sentinel
        sentinel = false
        for i in 1:n-1
            if arr[i] >= arr[i+1]
                arr[i], arr[i+1] = arr[i+1], arr[i]
                sentinel = true
                symbol += 2^i
            end
        end
    end
    return symbol
end

"""
calculates the permutation entropy of a signal

Segments of the signal are run through `findSymbol` to characterize
symbols based on the order of successive differences and then
calculating the entropy of the distribution of symbols
"""
function pentropy(arr :: Vector{Float64}, n :: Int64 = 3) :: Float64
    ll = length(arr)
    symbols = zeros(UInt32, ll-n+1)
    for i in 1:ll-n+1
        symbols[i] = findSymbol(arr[i:i+n-1])
    end

    #find entropy of symbols
    d = Dict()
    for i in symbols
        if i in keys(d)
            d[i] += 1
        else
            d[i] = 1
        end
    end

    #count symbols
    totalSymbols = sum(values(d))
    entropy = 0
    for j in keys(d)
        ee = d[j]/totalSymbols
        entropy += -ee * log2(ee)
    end

    return entropy
end


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


"""calculates wavelet entropy using Wavelets package"""
function waveletEntropy(signal :: Vector{Float64})
  coefentropy(signal, ShannonEntropy())
end

