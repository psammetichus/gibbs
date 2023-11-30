module SOBI

using LinearAlgebra
using Statistics

# from P-SOBI: A Parallel Implementation for Second Order Blind Identification Algorithm 
# 10.1109/HPCC/SmartCity/DSS.2019.00196


# X is an m × N matrix (N is number of samples, m is number of sensors)
# A is the mixing matrix, n × m, that maps the matrix of independent sources 
# (S ∈ R^n × N) to X (along with additive noise)
function sobi(X :: Array{Float64,2}, n :: Integer)
  m,N = size(X)
  defaultLags = 100
  #standardize
  X = X .- mean(X, dims=2)
  p = min(defaultLags, ceil(N/3))
  Rxx = X[:,1:N-1]*X[:,2:N]/(N-1)
  U,S,V = svd(Rxx)
  S = diagm(S)

  if n < m
    S = S-real(mean(S[n+1:m]))
    Q = diagm(real(√(1./S[1:n])))*U[:,1:n]
  else
    n = length(X[findall(x -> x>1e-99, D)])
    Q = diagm(real(√(1./S[1:n])))*U[:,1:n]
  end
  Xb = zeros(size(X))
  Xb[:,:] = Q*X[:,:] #prewhitened data

  #estimate time-delayed cov matrices
  k = 1
  pn = p*n
  for u in 1:m:pn
    k+=1
    Rxp = Xb[:,k:N]*Xb[:,1:N-k+1]'/(N-k+1)

    M[:,u:u+m-1] = norm(Rxp)*Rxp
  end

  #approximate joint diagonalization
  encore = 1
  Us = I(n)
  prec = 1/√(N)/100
  while encore
    encore = 0
    for p=1:n-1
      for q=p+1:n
        #Givens rotations
        g = [ M[p,p:n:pn] - M[q,q:n:pn] ;
              M[p,q:n:pn] + M[q,p:n:pn] ;
              im*(M[q,p:n:pn] - M[p,q:n:pn]) ]
        Ucp, D = eigen(real(g*g'))
        la, K = sort(diagm(D)) #is sort similar to matlab?
        angles = Ucp[:,K[3]]
        angles = sign(angles[1])*angles
        c = √(0.5+angles[1]/2)
        sr = 0.5*(angles[2]-j*angles[3])/c
        sc = conj(sr)
        asr = Int(abs(sr) > prec)
        encore = encore | asr
        if asr == 1
          colp = M[:,p:n:pn]
          colq = M[:,q:n:pn]
          M[:,p:n:pn] = c*colp+sr*colq
          M[:,q:n:pn] = c*colq-sc*colp
          rowp = M[p,:]
          rowq = M[q,:]
          M[p,:] = c*rowp+sc*rowq
          M[q,:] = c*rowq-sr*rowp
          temp = Us[:,p]
          Us[:,p] = c*Us[:,p] + sr*Us[:,q]
          Us[:,q] = c*Us[:,q] + sc*temp
        end #if
      end #q loop
    end #p loop
  end #while

  #estimate mixing matrix A
  A = pinv(Q)*Us[1:n,1:n]

  #estimate source activities
  W = Us[1:n,1:n]'*Q
  S = W*X[:,:]
  return A,S



  