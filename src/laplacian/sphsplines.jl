module SphSplines

import LegendrePolynomials as LP
using LinearAlgebra

# from "Spherical Splines and Average Referencing in Scalp Electroencephalography" 10.1007/s10548-006-0011-0

function gm(m :: Integer, N :: Integer, x :: Float64)
    weights = [(2n + 1)(n*(n+1))^m for n = 1:N]
    pls = LP.collectPl(x,N)[2:end]
    (weights *. pls)/4π
end

function Vest(r :: Vector{Float64}, cnull :: Float64, 
              c :: Vector{Float64}, electrodes :: Array{Float64,2},
              m :: Integer, N :: Integer) :: Float64
  cnull + sum( [c[i]*gm(m, N, r ⋅ electrodes[i]) for i = 1:length(electrodes)])
end


#from chapter 22 by John JB Allen 
#https://jallen.faculty.arizona.edu/sites/jallen.faculty.arizona.edu/files/Chapter_22_Surface_Laplacian.pdf
#

function cosdist(i,j)
    xi,yi,zi = i
    xj,yj,zj = j
    return 1 - ( (xi-xj)^2 + (yi-yj)^2 + (zi-zj)^2)/2
end #function cosdist

function gij(order, m, n, trodes)
    l = length(trodes)
    g = zeros( l,l)
    fourpi = 4π^-1
    for i in 1:l
        for j in 1:l
            for n = 1:order
                g[i,j] += (2n + 1)*LP.Plm(cosdist(trodes[i],trodes[j], n, order))/(n*(n+1))^m
            g[i,j] *= fourpi
    return g
end #gij

function hij(order, m, n, trodes)
    l = length(trodes)
    h = zeros( l,l)
    fourpi = 4π^-1
    for i in 1:l
        for j in 1:l
            for n = 1:order
                h[i,j] += -2*(n + 1)*LP.Plm(cosdist(trodes[i],trodes[j], n, order))/(n*(n+1))^(m-1)
            h[i,j] *= fourpi
    return h
end #hij

function lapl(i,t, data, λ=1e-5, G, H)
    nelec = size(G)[1]
    Gs = G + diagm(repeat([λ],nelec))
    di = data[i,t]^-1 * Gs
    Ci = zeros(nelec)
    for j in 1:nelec
       Ci += di/( 


end #module
