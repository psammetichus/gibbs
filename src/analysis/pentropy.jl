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

