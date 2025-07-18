# based on Source-sink connectivity: a novel interictal EEG marker for seizure localization
# by Gunnarsdottir et al. DOI: 10.1093/brain/awac300 
# with technique fully elaborated in DOI: 10.1109/EMBC.2017.8037439
# Linear Time-Varying Model Characterizes Invasive EEG Signals
# Generated from Complex Epileptic Networks

function estimateLTV(eeg :: Matrix{Float64})
    #eeg is NxT; N is number of electrodes, T is size of window
    N, T = size(eeg)
    b = reshape( eeg[:, 2:T], N*(T-1) )
    H = zeros(T-1, N*3)
    for i in 1:T-1
        for j in 1:3
            H[] #TODO
        end
    end
end #function

# b is N*(T-1); H is T-1 x N*3; X is N*N
# so if b = HX then b is 