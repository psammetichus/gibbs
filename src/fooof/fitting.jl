# funcs for model fitting
#
# taken from FOOOF
# Donoghue et al 2020 "Parameterizing neural power spectra into periodic and
# aperiodic components" DOI 10.1038/s41593-020-00744-x
#


function gaussianFittingModel(xs :: Vector{Float64}, p)
    μ, height, wid = p
    return height*exp.( -(xs .- μ).^2 ./ (2wid^2))
end #func

function expoFittingModel(xs :: Vector{Float64}, p)
    offset, expnt = p
    ys = zero(xs)
    ys = ys .+ (offset .- log10.(xs.^expnt))
    return ys
end #func

function linearFittingModel(xs :: Vector{Float64}, p)
    offset, slope = p
    ys = zero(xs)
    ys = ys .+ offset .+ (xs .* slope)
    return ys
end #func

function quadraticFittingModel(xs :: Vector{Float64}, p)
    offset, slope, curve = p
    ys = zero(xs)
    ys = ys .+ offset .+ (xs .* slope) + ( (xs.^2) .* curve)
    return ys
end #func

