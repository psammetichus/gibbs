Signal = Vector{Float64}

RMat = Array{Float64,2}


function spectralEdge(s :: Signal, Fs :: Float64, overlap :: Int64, width :: Int64, windower, k=0.95)
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
end
