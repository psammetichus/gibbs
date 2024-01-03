module EEGFilter

using Logging

#Zapline line noise cleaning algorithm based on https://github.com/MariusKlug/zapline-plus and the following papers:

#Klug, M., & Kloosterman, N. A. (2022).Zapline-plus: A Zapline extension for automatic and adaptiveremoval of frequency-specific noise artifacts in M/EEG.
#Human Brain Mapping,1–16. https://doi.org/10.1002/hbm.25832

#de Cheveigne, A. (2020) ZapLine: a simple and effective method to remove power line artifacts.
#NeuroImage, 1, 1-13. https://doi.org/10.1016/j.neuroimage.2019.116356



function zaplineCleanData(data, Fs; kwargs...)
    
    #warn that high sampling rates can affect results
    if Fs > 500
        @warn "It is recommended to downsample to 250–500 Hz or results may be suboptimal."
    end

    

end #function zaplineCleanData


end #module