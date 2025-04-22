#from PMID 23435210 "A Note on the Phase Locking Value and its Properties",
#Aydore et al. 2013


#requires Hilbert.jl


function phaseLockingValue(signal1, signal2)
    
    sig1 = eegSegment(signal1)
    sig2 = eegSegment(signal2)
    h1, h2 = hilbert.([sig1, sig2])
    s1, s2 = (signal1 + h1*im, signal2 + h2*im)
    Δϕ = angle.(s1 .* conj.(s2) ./ (abs.(s1) .* abs.(s2))) :: ComplexF64
    PLV = abs(exp.(Δϕ))

end #function
