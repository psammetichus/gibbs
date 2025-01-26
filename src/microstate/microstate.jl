#This is a part of Gibbs, (c) 2022–2025 Tyson Burghardt MD FAES


#variational microstates

function varMicro(X, K, reps, opts)
    FOpt = Inf
    KInd = 0
    for k in K
        KInd += 1
        FBest = Inf
        for r in 1:reps
            @info "starting initializations"
            vv = segmentation(X,K,opts)
        
        end
    end

end

function segmentation(X, K, maxIters, thresh, sig2_0, p0, opts)
    #X: C × N; Z: K × N; sig2_Z: K × N; A: C × K
    
    C,N = size(X)
    F = Inf
    FOld = 0
    tmp = (1-p0)/(K-1)
    smoothConst = log(1 + (p0 - tmp)/tmp)

    #random initialization of A, β, and S
    A = X[:,randperm(N,K)] ##need to juliafy it
    A = A / √(sum(A .* A))

    β = 1 / mean(var(X,0,2))

    S = rand(K,N)*0.1

    
end

function safeSoftMax(X)
    A = max(X, [], 1)
    X = X .- A

    X = exp.(X)
    X = X .* (1 ./ sum(X,1))
    X[findall(X .== 0)] = eps()
end

function freeEnergy(Z,sig2,sig2_0,S,β,C,N,K)
    F1 = -0.5*(N*K*log(2π) + sum(sum(log(sig2))) - N*K/2 + sum(sum(S.*log(S))))
    F2 = 0.5*K*N*log(2π*sig2_0) + sum(sum(Z.^2+sig2))/(2*sig2_0) + N*log(K)
    F3 = -C*N/2*log(β/2π) + C*N/2

    F = F1+F2+F3
    return F
end