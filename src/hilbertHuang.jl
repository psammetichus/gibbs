using Peaks
using BasicInterpolators

function emdRound(data)
    maxpeaks = findmaxima(data)
    minpeaks = findminima(data)
    maxinterp = CubicSplineInterpolator(maxpeaks, data[peaks])
    mininterp = CubicSplineInterpolator(minpeaks, data[peaks])
    l = length(data)
    emd = zeros(l)
    for i in 1:l
        emd[i] = (maxinterp[i] + mininterp[i])/2
    end #for
    return emd, (data .- emd)
end


end #function
