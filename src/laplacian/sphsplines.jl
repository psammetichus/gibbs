# from "The surface Laplacian technique in EEG: Theory and methods" 10.1016/j.ijpsycho.2015.04.023
#
# TODO: add regularization

function gm(m :: Integer, N :: Integer, x :: Float64)
    weights = [(2n + 1)/(n*(n+1))^m for n = 1:N]
    pls = collectPl(x,N)[2:end]
    (weights .* pls)/4π
end

function Gmij(m :: Integer, N :: Integer, l :: Integer, 
                        trodes :: Array{Float64,2})
    Gmij = zeros(l,l)
    for i in 1:l
      for j in 1:l
        Gmij[i,j] = gm(m,N,cosdist(trodes[i,:],trodes[j,:]))
      end
    end
    return Gmij
end
    
function laplacianTransformMatrix(m,n,λ,trodes)
  chans,_ = length(trodes)
  K = zeros(chans,chans)
  for i in 1:chans
    K[i,:] = [abs(trodes[j,:] .- trodes[i,:])^(2m-3) for j in 1:chans]
  end
  gm = Gmij(m,n,chans,trodes)
  Kbar = zeros(chans,chans)
  Kbar = -gm
  qrsol = qr(ones(chans))
  Q2 = qrsol.Q[:,2:end]
  Cλ = Q2*inv(Q2'*(K+ n*λ*I)*Q2)*Q2'
  return Kbar * Cλ
end

functional laplacianSphSpl(m,n,λ,eegdata :: EEG, trodes)
  data = eegdata.signals
  LTM = laplacianTransformMatrix(m,n,λ,trodes)
  return LTM*data'
end

function solveSphSplines( data :: Array{Float64}, trodes :: Array{Float64,2};
    m :: Integer = 3, N :: Integer = 64, Gmij :: Array{Float64,2})
    #data is Nchans x 1
    chans = length(data)
    A = zeros(chans+1,chans+1)
    for i in 1:chans
        A[i,1:chans] = [Gmij for j in 1:chans]
    end
    A[:,chans+1] = 1
    A[end,1:chans] = 1
    A[end,end] = 0
    b = cat(data, 0; dims=1)
    prob = LinearProblem(A, b)
    sol = solve(prob)
    return sol.u
end

function Vest(data, trodes, Gmij; m = 3, N = 64)
    #data is Nchans x Timepoints
    chans,T = length(data)
    Gmij = precompute_Gmij(m,N,chans,trodes)
    Vest = zeros(chans,T)
    for t in 1:T
      coeffs = solveSphSplines(m,N,data,trodes)
      for i in 1:chans
        Vest[i,t] = coeffs[end] + [coeffs[j]*Gmij[i,j] for j in 1:chans]
      end
    end
    return Vest
end

function cosdist(i :: Real, j :: Real)
    xi,yi,zi = i
    xj,yj,zj = j
    return 1 - ( (xi-xj)^2 + (yi-yj)^2 + (zi-zj)^2)/2
end 

