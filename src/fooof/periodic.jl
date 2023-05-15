function getBandPeakFM(fm, band, selectHighest=true,
    threshold=nothing, threshParam = "PW", attrib=:peakParams) :: RMat

    return getBandPeak(getfield(fm.attrs, attrib), band, selectHighest, threshold, threshParam)
end

function getBandPeakFG(fg, band, threshold=nothing, threshParam="PW", attrib=:peakParams) :: RMat
    #fg is a FOOOFGroup

    getBandPeakGroup(getfield(fg, attrib), band, length(fg), threshold, threshParam)
end

function getBandPeakGroup(peakParams, band, nFits, threshold=nothing, threshParam="PW")
    bandPeaks = zeros(nFits, 3)
    for ind in 1:nFits
        bandPeaks[ind, :] = getBandPeak(peakParams)
