module REST

import LinearAlgebra
using Statistics
using LegendrePolynomials

# data is the EEG potentials with average reference, chan x samples
# G is the lead field matrix, sources x channels

const RMat = Array{Float64, 2}

function rest_refer(data :: Rmat, G :: Rmat) :: Rmat

    G = G'

    channels = size(G,2)

    assert(size(data,1) == size(G,1)) #channel num should be the same

    assert(size(data,1) > size(data,2)) # need more time points than channels

    Gar = G - repeat(mean(a,dims=1),channels)

    dataZ = G * LinearAlgebra.pinv(Gar, 0.05) * data #value 0.05 for real data

    dataZ = data + repeat( mean(dataZ, dims=1), channels) # V = Vavg + AVG(V0)


end #rest_refer

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
  m*P[3]/sin(x₀[2])*Plm(cos(x₀[2]))*sin(m*x₀[3]) - P[2]/2*()


function calcLeadField(xyzElec, xyzDipoles, xyzDipOri, headmodel)
  
end #calcLeadField

end
