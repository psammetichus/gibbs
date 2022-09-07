module SphSplines

import LegendrePolynomials as LP

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




end #module
