#from PMID 23435210 "A Note on the Phase Locking Value and its Properties",
#Aydore et al. 2013


#requires Hilbert.jl


function phaseLockingValue(signal1, signal2)
    
    sig1 = eegSegment(signal1)
    sig2 = eegSegment(signal2)
    h1, h2 = hilbert.([sig1, sig2])
    Δϕ = angle.(h1 .* conj.(h2) ./ (abs.(h1) .* abs.(h2))) :: ComplexF64
    PLV = abs(exp.(Δϕ))

end #function
