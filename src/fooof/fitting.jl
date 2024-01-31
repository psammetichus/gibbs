# funcs for model fitting
#
# taken from FOOOF
# Donoghue et al 2020 "Parameterizing neural power spectra into periodic and
# aperiodic components" DOI 10.1038/s41593-020-00744-x
#


function gaussianFittingFunc(xs :: Vector{Float64}, params :: Vector{Tuple{Float64,Float64,Float64}})
    ys = zero(xs)

    for p ∈ params
        μ, height, wid = p
        ys .+= height*exp.( -(x.-μ).^2 ./ (2wid^2))
    end #for

    return ys
end #func


function expoFittingFunc(xs :: Vector{Float64}, params :: Tuple{Float64,Float64,Float64})
    ys = zero(xs)

    offset, knee, expnt = params

    ys = ys .+ (offset .- log10.(knee + xs.^expnt))

    return ys
end #func


function expoNoKneeFittingFunc(xs :: Vector{Float64}, params :: Tuple{Float64,Float64,Float64})
    ys = zero(xs)

    offset, expnt = params

    ys = ys .+ (offset .- log10.(xs.^expnt))

    return ys
end #func
