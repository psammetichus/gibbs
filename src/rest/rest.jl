
include("3000dipoles.jl")

# data is the EEG potentials with average reference, chan x samples
# G is the lead field matrix, sources x channels

const RMat = Array{Float64, 2}

function rREST_Hsc(n, indices)
    f = zeros(n,1)
    f[indices] .= 1
    return I(n) - ones(n,1).*f'
end

function genD(H)
    #genD is to eliminate covar structure 1/σ² * pinv(HHᵀ) of the
    #scalp noise. The solution is to take the SVD, take the sqrt and
    #plug it into the terms in the misfit function || v - H*ϕ ||²

    U,S,V = svd(H*H')
    d = diag(s)
    for (i,k) in enumerate(d)
        if k != 0.0
            d[i] = 1/√k
        end
    end
    return (U,diagm(d))
end


function rREST_vrbtrans(vr, K)
    Nc = size(vr,1)
    H0 = rRest_Hsc(Nc)

    #redefine H matrix to have identity covar of sensor noise
    U, D = genD(H0)
    H1 = D'*U'*H0
    V = D'*U'*vr

    #standard ridge regression form
    Uₖ, Sₖ, Vₖ = svd(K*K')
    L = Uₖ * pinv(sqrt(Sₖ))*Uₖ' #full lead field
    H = H1*pinv(L)
    return (V,H,L)
end


function rREST_core(data, K)

    Nc,Nt = size(data)
    data₁, H1, L = rREST_vrbtrans(data, K)
    U,S,V = svd(H1'*H1)
    s = diag(S)
    lmds = genlmd(1000)
    rss = zeros(size(lmds))
    df = zeros(size(lmds))
    data1_scaled = data₁ ./ norm(data₁)
    
    for i in  1:length(lmds)
        lmd = lmds[i]
        data₂ = H1*diag(1 ./ (s + lmd) ) * H1' * data1_scaled
        rss[i] = norm(data₂ - data1_scaled)^2
        df[i] = sum(s ./ (s + lmd))
    end

    gcv = rss ./ (Nc*Nt*df).^2


end

function calcTransformMatrix(V :: Rmat, est)
end

function invertG(G :: Rmat)
end

function calcRef(V, G)
end

function δ(i,j)
  if i == j
    return 1
  else
    return 0
  end
end

function g(m, l, x, x₀, P, δ₁,θ,ϕ)
  (x₀[1]^(l-1)/4πδ₁ )*(2-δ(m,0))*( factorial(l-m)/factorial(l+m))*(l*P[0]*Plm(cos(x₀[2])*cos(m*x₀[3])) -
  m*P[3]/sin(x₀[2])*Plm(cos(x₀[2]))*sin(m*x₀[3]) - P[2]/2*())
end #function

function calcLeadField(xyzElec, xyzDipoles, xyzDipOri, headmodel)
  
end #calcLeadField


function genlmd(np)

    return exp10.(range(2,3,np))'

end