# funcs for model fitting
#
# taken from FOOOF
# Donoghue et al 2020 "Parameterizing neural power spectra into periodic and
# aperiodic components" DOI 10.1038/s41593-020-00744-x
#


function gaussianFittingFunc(xs :: Vector{Float64}, μ, height, wid)
    ys = zero(xs)
    ys = ys .+ height*exp.( -(x - μ).^2 ./ (2wid^2))
    return ys
end #func


function expoFittingFunc(xs :: Vector{Float64}, offset, knee, expnt)
    ys = zero(xs)
    ys = ys .+ (offset .- log10.(knee + xs.^expnt))
    return ys
end #func


function expoNoKneeFittingFunc(xs :: Vector{Float64}, offset, expnt)
    ys = zero(xs)
    ys = ys .+ (offset .- log10.(xs.^expnt))
    return ys
end #func

function linearFittingFunc(xs :: Vector{Float64}, offset, slope)
    ys = zero(xs)
    ys = ys .+ offset .+ (xs .* slope)
    return ys
end #func

function quadraticFittingFunc(xs :: Vector{Float64}, offset, slope, curve)
    ys = zero(xs)
    ys = ys .+ offset .+ (xs .* slope) + ( (xs.^2) .* curve)
    return ys
end #func

