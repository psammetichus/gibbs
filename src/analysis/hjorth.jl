# Hjorth parameters
# taken from "EEG Analysis Based on Time Domain Properties", Hjorth, 1970

function hjorthActivity(s :: Vector{Float64})
    return var(s)
end #function

function hjorthMobility(s :: Vector{Float64})
    return sqrt(var(diff(s))/var(s))
end #function

function hjorthComplexity(s :: Vector{Float64})
    return hjorthMobility(diff(s))/hjorthMobility(s)
end #function
