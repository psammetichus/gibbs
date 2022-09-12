module SOBI

using LinearAlgebra

using SIMD

# from P-SOBI: A Parallel Implementation for Second Order Blind Identification Algorithm 
# 10.1109/HPCC/SmartCity/DSS.2019.00196


# X is an m × T matrix (T is number of samples, m is number of sensors)
# A is the mixing matrix, n × m, that maps the matrix of independent sources 
# (S ∈ R^n × T) to X (along with additive noise)
function sobi(X :: Array{Float64,2}, n) :: Array{Float64,2}
  m = length(X)[0]
  A = zeros(n, m)
  while encore
    encore = 0
    for p in 1:(m-1)
      for Ip in p:m:n*m
        for q in (p+1):m
          for Iq in q:m:n*m
            g = [
                 A[p,Ip] - A[q,Iq];
                 A[p,Iq] + A[q,Ip];
                 A[q,Ip] - A[p,Iq]
                ]
            F = eigen(g * g')
            ix = sortperm(diag(F.values))
            eigv = F.vectors[:,ix]
            lam = F.values[ix]
            angles = sign( ix[3,1]
          end
        end
      end
    end
  end
end #module


function simdSobi(X :: Array{Float64,2}, n) :: Array{Float64,2}
  m = length(X)[0]
  A = zeros(n, m)

  while encore
    encore = 0
      for p in 1:(m-1), Ip in p:m:n*m
        for q in (p+1)
      end #for
  end #while



end #function
