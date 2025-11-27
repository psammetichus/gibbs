import LegendrePolynomials as LP
using LinearAlgebra

# from "Spherical Splines and Average Referencing in Scalp Electroencephalography" 10.1007/s10548-006-0011-0

function gm(m :: Integer, N :: Integer, x :: Float64)
    weights = [(2n + 1)/(n*(n+1))^m for n = 1:N]
    pls = LP.collectPl(x,N)[2:end]
    (weights .* pls)/4π
end

function solveSphSplines(m :: Integer, N :: Integer, data :: Array{Float64}, trodes :: Array{Float64,2})
    #data is Nchans x 1
    chans = length(data)
    A = zeros(chans+1,chans+1)
    for i in 1:chans+1
        A[i,1:chans] = [gm(m,N,cosdist(trodes[i,:],trodes[j,:])) for j in 1:chans] 
    end
    A[:,chans+1] = 1
    A[end,1:chans] = 1
    A[end,end] = 0
    b = cat(data, 0; dims=1)
    prob = LinearProblem(A, b)
    sol = solve(prob)
    return sol.u
end

function Vest(m, N, data, trodes)
    #data is Nchans x Timepoints
    coeffs = solveSphSplines(m,N,data,trodes)
    Vest = zeros(chans)
    for i in 1:chans
        Vest[i] = coeffs[end] + [coeffs[j]*gm(m,N,cosdist(trodes[i],trodes[j])) for j in 1:chans]
    end
    return Vest
end


function cosdist(i,j)
    xi,yi,zi = i
    xj,yj,zj = j
    return 1 - ( (xi-xj)^2 + (yi-yj)^2 + (zi-zj)^2)/2
end #function cosdist

