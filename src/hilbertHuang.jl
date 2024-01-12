using Peaks
using BasicInterpolators
using DSP

# using stop criteria as outlined in Rilling, G., Flandrin, P., & Goncalves, P.
# (2003, June). On empirical mode decomposition and its algorithms. In
# IEEE-EURASIP workshop on nonlinear signal and image processing (Vol. 3, No. 3,
# pp. 8-11). Grado: IEEE.


function emdRound(data, θ1=0.05, θ2=0.5, α=0.05)
    maxpeaks = findmaxima(data)
    minpeaks = findminima(data)
    maxinterp = CubicSplineInterpolator(maxpeaks, data[peaks])
    mininterp = CubicSplineInterpolator(minpeaks, data[peaks])
    l = length(data)
    imf = zeros(l)
    ma = zeros(l)
    for i in 1:l
        #intrinsic mode function
        imf[i] = (maxinterp[i] + mininterp[i])/2
        #calculate mode amplitude
        ma[i] = (maxinterp[i] - mininterp[i])/2
        σ[i] = absolute(imf[i]/ma[i])
    end #for

    stopOrNot = false
    #test
    θfractn = (1-α)*l
    howmany = any(x -> x<θ1, σ)
    if length(howmany) > θfractn
        if all(x -> x< θ2, σ)
            stopOrNot = true
        end
    end

    #return the intrinsic mode function, the residual, and the stop flag
    return imf, (data .- emd), stopOrNot
end


function emd(data, θ1=0.05, θ2=0.5, α=0.05)
    stop = false
    imfs = []
    resid = data
    while stop == false
        imfn, resid, stopOrNot = emdRound(resid, θ1, θ2, α)
        stop = stopOrNot
        vcat(imfs, imfn)
    end #while
    return imfs
end #function

function hilbertHuang(data, θ1=0.05, θ2=0.5, α=0.05)
    imfs = emd(data, θ1, θ2, α)
    himfs = zeros(Complex128, (rows,cols))
    rows, cols = size(imfs)
    for i in 1:rows
        himfs[i,:] = hilbert(imfs[i,:])
    end #for
    return himfs
end #function

end #function
