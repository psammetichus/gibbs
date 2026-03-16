# funcs for model fitting
#
# taken from FOOOF
# Donoghue et al 2020 "Parameterizing neural power spectra into periodic and
# aperiodic components" DOI 10.1038/s41593-020-00744-x
#

function multiGaussianFittingModel(p, xs :: Vector{Float64})
    #p is a vector of tuples
    ys = zero(xs)
    for i in length(p)/3
        ys = ys .+ p[i+2].*exp.( -(xs .- p[i+0]).^2 ./ (2 .* p[i+1].^2))
    end
    return ys
end #func

function gaussianFittingModel(p, xs :: Vector{Float64})
    μ, width, height = p
    return height .* exp.( -(xs .- μ).^2 ./ (2width.^2))
end

function expoKneeFittingModel(p, xs :: Vector{Float64})
    offset, expnt, knee = p
    return offset .- log10(knee .+ xs .^ expnt)
end #func

function expoNoKneeFittingModel(p, xs :: Vector{Float64})
    offset, expnt = p
    return offset .- log10(xs .^ expnt)
end



