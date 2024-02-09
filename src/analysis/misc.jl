function spectralEdge(s :: Vector{Float64}, Fs :: Float64, overlap :: Int64, width :: Int64, windower, k=0.95)
    ll = length(s)
    lls = zeros(ll - overlap)
    i = 1
    while i < ll - overlap
        segment = windower(s[i:i+width])
        ffs = rfft(segment)
        ssum = 0.0
        total = sum( abs.(ffs).^2 )
        edge = k*total
        for j in 1..div(width,2)+1
            ssum += abs(ffs[j])^2
            if ssum >= edge
                lls[i] = (j/(div(width,2)+1) * div(Fs, 2))
            end
        end
        i += overlap
    end
    return lls
end #func

# line length functions from Line length: An efficient feature for seizure onset detection, Esteller et al, 2001

function lineLength(s :: Vector{Float64})
    l = 0
    p = length(s)
    for i ∈ 1:p-1
        l += abs(s[i+1]-s[i])
    end #for
    return l
end #func

function lineLengthNorm(s :: Vector{Float64}, N, K=N)
    ll = zeros(length(s)-N)
    for n ∈ N+1:length(s)
        ll[n-N] = lineLength(s[n-N:n])/K
    end #for
    return ll
end
