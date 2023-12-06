module SOBI

using LinearAlgebra
using Statistics

# from P-SOBI: A Parallel Implementation for Second Order Blind Identification Algorithm 
# 10.1109/HPCC/SmartCity/DSS.2019.00196


# X is an m × N matrix (N is number of samples, m is number of sensors)
# A is the mixing matrix, n × m, that maps the matrix of independent sources 
# (S ∈ R^n × N) to X (along with additive noise)
function sobi(X :: Array{Float64,2})
  m,N = size(X)
  n = m
  defaultLags = 100
  #standardize and whiten
  X = standardize(X)
  #Q = whitenTransformation(X)
  #X = Q*X
  
  #estimate delayed time cov matrices
  M = estTimeDelayedCov(X, 100)
  
  #conduct approx joint diagonalization
  U = ajd(X,M)

  #estimate mixing matrix A
  A = pinv(Q)*U[1:n,1:n]
  
  #estimate source activities
  W = U[1:n,1:n]'*Q
  S = W*X
  return A,S
end #function

function standardize(X :: Array{Float64,2}) :: Array{Float64,2}
  return X .- mean(X, dims=2)
end

function whitenTransformation(X :: Array{Float64,2})
  #scaled by 1 over the sqrt of the eigenvalues
  m,N = size(X)
  Rxx = X[:,1:N-1]*X[:,2:N]'/(N-1) #estimate covariance matrix with time lag 1
  vals,vecs = eigen(Rxx)
  vals = 1 ./ sqrt.(vals)
  return diagm(vals)
  #not correct
end

function estTimeDelayedCov(X :: Array{Float64,2}, lags=100)
  m,N = size(X)
  n = m
  k = 1
  p = Int(min(lags, ceil(N/3)))
  pn = p*n
  M = zeros(ComplexF64, m,pn)
  for u in 1:m:pn
    k += 1
    Rxp = X[:,k:N]*X[:,1:N-k+1]'/(N-k+1) #m x m matrix
    M[:,u:u+m-1] = norm(Rxp)*Rxp
    
  end
  return M
end

function ajd(X :: Array{Float64,2}, M :: Array{ComplexF64,2})
  #approximate joint diagonalization
  m,N = size(X)
  n = m
  pn = size(M)[2]
  encore = true
  Us = diagm(repeat([1.0+0.0im], n))
  ϵ = 1/√(N)/100
  while encore 
    encore = false
    for p=1:n-1
      for q=p+1:n
        pn = 100*n
        #Givens rotations
        g = [ M[p,p:n:pn] - M[q,q:n:pn] ;
              M[p,q:n:pn] + M[q,p:n:pn] ;
              im*(M[q,p:n:pn] - M[p,q:n:pn]) ]
        D, Ucp = eigen(real(g*g'))
        K = sortperm(diagm(D), dims=1) 
        angles = Ucp[:,K[3]] #how does this work
        angles = sign(angles[1])*angles
        c = √(0.5+angles[1]/2)
        sr = 0.5*(angles[2] - im*angles[3])/c
        sc = conj(sr)
        asr = abs(sr) > ϵ
        encore = encore || asr
        if asr
          colp = M[:,p:n:pn]
          colq = M[:,q:n:pn]
          M[:,p:n:pn] = c * colp + sr * colq
          M[:,q:n:pn] = c * colq - sc * colp
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
  return Us
end #function

end #module