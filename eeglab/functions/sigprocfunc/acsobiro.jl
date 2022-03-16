# Gibbs
# Open-source EEG analysis software coded in Julia
# (c)2022 Tyson Burghardt MD FAES
#
# Offered under the GPLv3
#
# acsobiro
#
#

module acsobiro

require eegbase
using LinearAlgebra

# acsobiro() - A. Chickocki's robust Second-Order Blind Identification (SOBI) 
#              by joint diagonalization of the time-delayed covariance matrices. 
#              NOTE: THIS CODE ASSUMES TEMPORALLY CORRELATED SIGNALS.
#              Thus, the estimated time-delayed covariance matrices 
#              for at least some time delays must be nonsingular.
#
# Usage:  acsobiro(X :: Matrix{Float64}) :: Matrix{Float64}
#         acsobiro(X::Matrix{Float64}, n::Int64, p::Int64)::(Matrix{Float64}, Matrix{Float64})
# Inputs: 
#         X - data matrix of dimension [m,N] where
#                    m is the number of sensors
#                    N is the number of samples
#         n - number of sources {Default: n=m}
#         p - number of correlation matrices to be diagonalized {default: 100}
#             For noisy data, use at least 100 time delays.
# Outputs:
#         H - matrix of dimension [m,n] an estimate of the *mixing* matrix
#         S - matrix of dimension [n,N] an estimate of the source activities
#             where  >> X [m,N] = H [m,n] * S [n,N]
#
# Authors: Implemented and improved by A. Cichocki on the basis of 
#          the classical SOBI algorithm of Belouchrani and publications of: 
#            A. Belouchrani et al., F. Cardoso et al.,
#            S. Choi, S. Cruces, S. Amari, and P. Georgiev
#          For references: see function body
#
# Note: Extended by Arnaud Delorme and Scott Makeig to process data epochs
#       (computes the correlation matrix respecting epoch boundaries).

# REFERENCES:
#  A. Belouchrani, K. Abed-Meraim, J.-F. Cardoso, and E. Moulines, ``Second-order
#  blind separation of temporally correlated sources,'' in Proc. Int. Conf. on
#  Digital Sig. Proc., (Cyprus), pp. 346--351, 1993.
#
#  A. Belouchrani, and A. Cichocki, 
#  Robust whitening procedure in blind source separation context, 
#  Electronics Letters, Vol. 36, No. 24, 2000, pp. 2050-2053.
#  
#  A. Cichocki and S. Amari, 
#  Adaptive Blind Signal and Image Processing, Wiley,  2003.

const RMatrix = Matrix{Float64}

function acsobiro(X::Array{Float64,3},
                  n::Int64=0,
                  p::Int64=100)::TupleArray{RMatrix, RMatrix}

  default_lags = 100
  m,N,ntrials = size(X)
  if n == 0
    n = m
  end
  p = min(default_lags, Int64(ceil(N/3)))
  X = X .- mean(reshape(X, m, n*ntrials), dims=2) #remove data means

  #estimate sample cov matrix for time delay 1 to reduce influence of wh noise
  Rxx = zeros(m,m)
  for t in 1:ntrials
    rr = (X[:,1:N-1,t]*X[:,2:N,t]')/(N-1)/ntrials
    Rxx += rr
  end

  F = svd(Rxx)

  if n<m # assumes additive wh noise and when num of src known or estimated a priori
    Dx = Dx - real( (mean(Dx[n+1:m])))
  else
    n=max( findall(x -> x>1e-99, Dx))
    print("acsobiro(): est num src is ", n)
  end

  Q = Diagonal(real(sqrt(1 ./ Dx[1:n]))) * Ux[:,1:n]'

  Xb = zeros(size(X))
  Xb = reshape(Q*reshape(X,m,N*ntrials),m,N,ntrials) #prewhitened data


  #estimate time-delayed cov matrices

  k = 1
  pn = p*n #convenience
  M = zeros(m,size(1:m:pn)[1])
  for u in 1:m:pn
    k+=1
    Rxp = zeros(m,m)
    for t in 1:ntrials
      rr = (Xb[:,k:N,t]*Xb[:,1:N-k+1,t]')/(N-k+1)/ntrials
      Rxp += rr
    end
    M[:,u:u+m-1] = norm(Rxp, p=2)*Rxp
  end
      
  eps = 1/sqrt(N)/100
  encore = 1
  U = I(n)

  while encore
    encore = 0
    for p in 1:n-1
      for q in p+1:n
        #Givens rotations
        g = [
             M[p,p:n:pn] - M[q,q:n:pn] ;
             M[p,q:n:pn] + M[q,p:n:pn] ;
             i*(M[q,p:n:pn] - M[p,q:n:pn])
            ]
        Ucp, D = eigen(real(g*g'))
        la, K = sort( Diagonal(D) )
        angles = Ucp[:,K[3]]
        angles *= sign(angles[1])
        c = sqrt(0.5+angles[1]/2)
        sr = 0.5*(angles[2] - im*angles[3])/c
        sc = conj(sr)
        asr = abs(sr) > eps
        encore = encore | asr
        if asr # update M and U
          colp = M[:,p:n:pn]
          colq = M[:,q:n:pn]
          M[:,p:n:pn] = c*colp + sr*colq
          M[:,q:n:pn] = c*colq - sc*colp
          M[p,:] = c*M[p,:] + sc*M[q,:]
          M[q,:] = c*M[q,:] - sc*M[p,:]
          temp = U[:,p]
          U[:,p] = c*U[:,p] + sr*U[:,q]
          U[:,q] = c*U[:,q] - sc*temp
        end #if
      end #for q
    end #for p
  end #while

  #estimate mixing matrix H
  H = pinv(Q)*U[1:n,1:n]

  #estimate source activities
  W = U[1:n,1:n]' * Q
  S = W*reshape(X,m,N*ntrials) #not sure thsi works out how I think; how does matlab doe X(:,:)

  return (H, S)

end # function


end # module
