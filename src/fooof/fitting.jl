# funcs for model fitting
#
# taken from FOOOF
# Donoghue et al 2020 "Parameterizing neural power spectra into periodic and
# aperiodic components" DOI 10.1038/s41593-020-00744-x
#


function gaussianFittingFunc(xs :: Vector{Float64}, params :: Vector{Tuple{Float64,Float64,Float64}}) :: Vector{Float64}
    ys = zero(xs)

    for p in params:
        μ, height, wid = p
        ys .+= height*exp.( -(x.-μ).^2 ./ (2wid^2))
    end #for

    return ys
end #func


function expoFittingFunc(xs :: Vector{Float64}, params :: Tuple{Float64,Float64,Float64}) :: Vector{Float64}
    ys = zero(xs)

    offset, knee, expnt = params

    ys = ys .+ (offset .- log10.(knee + xs.^expnt))

    return ys
end

function expoNKFittingFunction(xs :: Vector{Float64}, params :: Tuple{Float64,Float64}) :: Vector{Float64}
    ys = zero(xs)

    offset, expnt = params

    ys = ys .+ offset .- log10.(xs.^expnt)

    return ys
end

function linearFittingFunction(xs :: Vector{Float64}, params :: Tuple{Float64, Float64}) :: Vector{Float64}
    ys = zero(xs)
    offset, slope = params

    ys = ys .+ offset .+ (xs.*slope)

    return ys
end

function quadraticFittingFunction(xs :: Vector{Float64}, params :: Tuple{Float64, Float64, Float64}) :: Vector{Float64}
    ys = zero(xs)
    offset, slope, curve = params

    ys = ys .+ offset .+ (xs.*slope) .+ ( ( xs .^2 ) .* curve)

    return ys
end

function getPEFunc(periodicMode :: String))
    if periodicMode == "gaussian"
        peFunc = gaussianFittingFunc
    else
        error("requested periodic mode not understood")
    end
    return peFunc
end

function getAPFunc(aperiodicMode :: String)
    if aperiodicMode == "fixed"
        apFunc = expoNKFittingFunction
    elseif aperiodicMode == "knee"
        apFunc = expoFittingFunc
    else
        error("requested aperiodic mode not understood")    
    end

    return apFunc
end

function inferAPFunc(aperiodicParams :: Tuple{Float64, Float64}) :: String
    return "fixed"
end

function inferAPFunc(aperiodicParams :: Tuple{Float64, Float64, Float64}) :: String
    return "knee"
end


