#from https://github.com/GoldenholzLab/CHOCOLATE
#
#needs using Distributions
#

function getMSF(SF)
    #TODO
end


function simulate_diary(sampRate, nSamps, SFParams, retDeets, cycParams, maxLims, Lparams, clusterParams)
    if sampRate > 144
        error("no more than every 10 min")
    end #if

    cycTF, clusterProb, clustTime, clustMax, eachClustProb = clusterParams

    mSF = getMSF(SFParams)
    
    #generate basic rate (think of as basic sz susceptibility)
    #monthly -> daily rate
    SF = mSF / 30
    #calc overdispersion parameter
    tempdisp = Lparams[0]*np.log10(max([0.001,SF + Lparams[1]])) + Lparams[2]*np.log10(max([0.001,SF + Lparams[3]]))  + Lparams[4]

    overdispersion = max(Lparams[1], tempdisp)

    rate = rand(Gamma(1/(sampRate*overdispersion), SF*overdispersion), nSamps)

    #keep going
end #function
