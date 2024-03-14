"""
takes a collection of signals and calculates independent sources based on
second-order blind identification (SOBI). Algorithm taken from EEGLab but uses
`Diagonalizations.jl` to perform the approximate joint diagonalization.

# Arguments
- X is an m × N matrix (N is number of samples, m is number of sensors)

- A is the mixing matrix, n × m, that maps the matrix of independent sources to X along with
additive noise

- (S ∈ R^n × N) is the matrix of independent sources
"""
function sobi(X :: Array{Float64,2})
  m,N = size(X)
  n = m
  defaultLags = 100
  #standardize and whiten
  @info "Standardizing data matrix..."
  X = standardize(X)
  @info "Whitening transformation calculated..."
  Q = whitenTransformation(X)
  X = Q*X
  
  #estimate delayed time cov matrices
  @info "Estimating lagged covariance matrices..."
  M = estTimeDelayedCov(X, 100)
  
  #conduct approx joint diagonalization
  @info "Approximate joint diagonalization starting..."
  U = ajd(X,M...)

  #estimate mixing matrix A
  @info "Estimating mixing matrix..."
  A = pinv(Q)*U[1:n,1:n]
  
  #estimate source activities
  @info "Estimating source activities..."
  W = U[1:n,1:n]'*Q
  S = W*X
  return A,S
end #function

"detrends a signal by subtracting the mean"
function standardize(X :: Array{Float64,2}) :: Array{Float64,2}
  return X .- mean(X, dims=2)
end

function whitenTransformation(X :: Array{Float64,2})
  #scaled by 1 over the sqrt of the eigenvalues
  m,N = size(X)
  Rxx = X[:,1:N-1]*X[:,2:N]'/(N-1) #estimate covariance matrix with time lag 1
  vals,vecs = eigen(Rxx)
  vals = 1 ./ real.(sqrt.(vals))
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
