using Toml

@enum Polarity positive negative

struct MontageChannel
    signalCombo :: Array{Float64, 1}
    sens :: Float64
    polarity :: Polarity
    color :: Tuple(Float64, Float64, Float64)
end #struct

mutable struct Montage
    signalTransforms :: Matrix{Float64}
    sensitivities :: Vector{Float64}
    polarities :: Vector{Polarity}
    colors :: Vector{Tuple{Float64, Float64, Float64}}
end #struct

function addMontageChan(m :: Montage, ch :: MontageChannel)
    m.signalTransforms = hcat( m.signalTransforms, ch.signalCombo)
    push!(m.sensitivities, ch.sens)
    push!(m.polarities, ch.polarity)
    push!(m.colors, ch.color)
end #function

function emptyMontage()
    return Montage([], [], [], [])
end #function