"""
calculates the vector of spectral edge frequencies parameterized by `k` of a signal 
"""
function spectralEdge(s :: Vector{Float64}, Fs :: Float64, k=0.95)
    ll = length(s)
    ffs = rfft(s)
    ssum = 0.0
    total = sum( abs.(ffs).^2 )
    edge = k*total
    for j in 1:div(width,2)+1
        ssum += abs(ffs[j])^2
        if ssum >= edge
            return (j/(div(width,2)+1) * div(Fs, 2))
        end
    end
    return Fs/2
end #func

# line length functions from Line length: An efficient feature for seizure onset detection, Esteller et al, 2001

"calculates the line length of a signal (the sum of the absolute values of successive differences)"
function lineLength(s :: Vector{Float64})
    l = 0
    p = length(s)
    for i ∈ 1:p-1
        l += abs(s[i+1]-s[i])
    end #for
    return l
end #func

"calculates a vector of normalized line lengths parameterized by the size of each segment"
function lineLengthNorm(s :: Vector{Float64}, N, K=N)
    ll = zeros(length(s)-N)
    for n ∈ N+1:length(s)
        ll[n-N] = lineLength(s[n-N:n])/K
    end #for
    return ll
end
