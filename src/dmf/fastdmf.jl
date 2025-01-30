# part of Gibbs ©2022-2025 Tyson Burghardt
# translated from FastDMF C++ implementation
# at https://gitlab.com/concog/fastdmf/-/blob/master/cpp/DMF.hpp

function clip(x :: Float64)
    return x > 1 ? 1.0 : (x < 0 ? 0.0 : x)
end

mutable struct DMFSimParams
    dt :: Float64
    I0 :: Float64
    w :: Float64
    JN :: Float64
    C :: Matrix{Float64}
    G :: Float64
    γ :: Float64
    σ :: Float64
    taog :: Float64
    taon :: Float64
    gₑ :: Float64
    gᵢ :: Float64
    Iₑ :: Float64
    Iᵢ :: Float64
    dₑ :: Float64
    dᵢ :: Float64
    dtt :: Float64
    nbSteps :: UInt64
    N :: UInt64
    batchSize :: UInt64
    stepsPerMS :: UInt64
    seed :: UInt64
    returnRate :: Bool
    returnBold :: Bool
    sn :: Vector{Float64}
    sg :: Vector{Float64}
    J :: Vector{Float64}
    receptors :: Vector{Float64}
    Jextₑ :: Vector{Float64}
    Jextᵢ :: Vector{Float64}
    wgainₑ :: Vector{Float64}
    wgainᵢ :: Vector{Float64}
end

function curr2rate(x :: Vector{Float64}, wgain, g, I, d, p)
    y = g*(x.-I) * (1+p.receptors+wgain)
    return y / (1-exp(-d*y))
end

function run(p :: DMFSimParams, rateRes :: Array{Float64,2})
    if p.returnBold
        @info "BOLD integrator not implemented."
    end
    fill!(p.sn, 0.001)
    fill!(p.sg, 0.001)
    rateSize = p.returnRate ? p.nbSteps : 2*p.batchSize
    n = Normal(0, √p.dt * p.σ)
    Random.seed!(p.seed)
    rnd = zeros(p.N)
    
    for t in 0:p.nbSteps-1
        rateIdx = t % rateSize

        for d in 0:p.stepsPerMS-1
            xn = p.I0 .* p.Jextₑ + p.w*p.JN .* p.sn + p.G * p.JN * (p.C * p.sn) - p.J.*p.sg
            xg = p.I0 .* p.Jextᵢ + p.JN*p.sn - p.sg

            rateRes[:,rateIdx] = curr2rate(xn, p.wgainₑ, p.gₑ, p.Iₑ, p.dₑ)
            rg = curr2rate(xg, p.wgainᵢ, p.gᵢ, p.Iᵢ, p.dᵢ)
            rnd = rand(n, p.N)
            sg += p.dt * (-sg/p.taog + rg/1000) + rnd
            sg = clip.(sg)
        end


    end
    return rateRes
end
