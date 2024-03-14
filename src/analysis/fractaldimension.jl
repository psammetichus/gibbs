#implemented based on A note on fractal dimensions of biomedical waveforms, B.S. Raghavendra∗, D. Narayana Dutt 2009

function katzFD(t :: Vector{Float64})
    c = [t' ; (1:length(t))']
    n = length(t)-1
    L = sum([√sum((c[:, i+1] - c[:,i]).^2) for i ∈ 1:n])
    d = maximum([√sum((c[:, i+1] - c[:,1]).^2) for i ∈ 1:n])
    return log(n)/(log(n)+log(d/L))
end #function

#implemented based on Wikipedia fetched 2024-03-13 and the above

function higuchiFD(y :: Vector{Float64}, kmax=10)
    L = zeros(kmax)
    N = length(y)
    for k in 1:kmax
        Lk = zeros(k)
        for m in 1:k
            M = floor(Int, (N-m)/k)
            Lk[m] = (N-1)/(M*k^2) * sum([abs(y[m+i*k] - y[m+(i-1)*k]) for i in 1:M])
        end #for m
        L[k] = 1/k * sum(Lk)
    end #for k
    points = DataFrame(y = log.(L), x = log.(1:kmax))
    return -coef(lm(@formula(y ~ x), points).model)[2]
end #function
