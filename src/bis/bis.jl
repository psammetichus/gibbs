module BIS

#a module for calculating the bispectral index of an EEG (or other signal,
#frankly) based on the reverse-engineered algorithm presented by
#DOI:10.1038/s41598-019-50391-x 

using DSP
using Basics

function linearbis(which :: String, bsrCoeff, sefCoeff, rbrCoeff, emgCoeff)
    if which == "green"
        -0.42bsrCoeff + 42.1
    end 
    if which == "orange"
        -0.42bsrCoeff + 0.91sefCoeff + 3.06rbrCoeff + 0.04emgCoeff + 29.9
    end
    if which == "green"
        -3.01bsrCoeff + 3.84sefCoeff - 8.70rbrCoeff + 0.96emgCoeff - 57.6
    end
    if which == "blue"
        -1.43bsrCoeff + 2.55sefCoeff + 4.26rbrCoeff + 0.41emgCoeff + 5.3
    end
    if which == "purple"
        -1.97bsrCoeff + 0.88sefCoeff + 7.89rbrCoeff - 0.07emgCoeff + 65.2
    end
end



function bsr(sig :: Signal)
    
end

function bis(sig :: Signal)
    BSR = bsr(sig)
    if BSR > 0.498
        return linearbis("green", BSR, 0.0, 0.0, 0.0)
    end
    
    EMG = emg(sig)
    SEF = sef(sig)
    RBR = rbr(sig)
    if EMG < 34.2 && SEF < 20.2
        if BSR > 0.021 || SEF < 14.8
            return linearbis("orange", BSR, SEF, RBR, EMG)
        else
            return linearbis("green", BSR, SEF, RBR, EMG)
        end
    else
        if RBR < -0.7
            return linearbis("blue", BSR, SEF, RBR, EMG)
        else
            return linearbis("purple", BSR, SEF, RBR, EMG)
        end
    end
end #function bis



end #BIS
