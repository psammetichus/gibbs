module RUNICA

function runica(data :: Matrix{Float64}; kwargs...)
    chans, frames = size(data)
    urchans = chans
    datalength = frames

    MAX_WEIGHT          =       1e8
    DEFAULT_STOP        =       0.000001
    DEFAULT_ANNEALDEG   =       60
    DEFAULT_ANNEALSTEP  =       0.90
    DEFAULT_EXTANNEAL   =       0.98
    DEFAULT_MAXSTEPS    =       512
    DEFAULT_MOMENTUM    =       0.0

    DEFAULT_BLOWUP      =       1000000000.0
    DEFAULT_BLOWUP_FAC  =       0.8
    DEFAULT_RESTART_FAC =       0.9

    MIN_LRATE           =       0.000001
    MAX_LRATE           =       0.1
    DEFAULT_LRATE       =       0.00065/log(chans)

    DEFAULT_BLOCK       =       ceil(min(5*log(frames), 0.3*frames))

    DEFAULT_EXTENDED    =       false
    DEFAULT_EXTBLOCKS   =       1
    DEFAULT_NSUB        =       1

    DEFAULT_EXTMOMENTUM =       0.5
    MAX_KURTSIZE        =       6000
    MIN_KURTSIZE        =       2000
    SIGNCOUNT_THRESHOLD =       25

    SIGNCOUNT_STEP      =       2

    DEFAULT_SPHEREFLAG  =       true
    DEFAULT_INTERRUPT   =       false
    DEFAULT_PCAFLAG     =       false
    DEFAULT_POSACTFLAG  =       false
    DEFAULT_VERBOSE     =       true
    DEFAULT_BIASFLAG    =       true
    DEFAULT_RESRNDSEED  =       true

    #setup kw defaults

    epochs = 1
    pcaflag = "completeme"
    
end #function

end #module