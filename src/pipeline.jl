using .Filtering
using .SOBI

function zeroExtend(arr, i, l, segLength)
    if l-i+1 > segLength
        return arr[i:i+segLength]
    else
        zex = zeros(segLength)
        zex[1:l-i+1] = arr[i:end]
        return zex
    end #if
end #function

function segment(data :: Array{Float64,1}, segLength = 1024)
    l = length(data)
    segms = ceil(l/segLength)
    collection = undef(segms)
    j = 1
    for i in 1:segLength:l
        a[j] = zeroExtend(data, i, l, segLength))
        j +=1
    end #for
    return collection
end #function

function filter(eeg :: EEG, bp, notch=false, Fs)
    filtered = eegFirFilter!(data, bp)
    #now clean with SOBI
    dataMatrix = hcat(values(eeg.signals))
    A,S = sobi(dataMatrix)
    for i in 1:size(dataMatrix,1)
        dataMatrix[i,:] = dataMatrix[i,:] - S[1,:]
    end #for
    