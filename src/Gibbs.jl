module Gibbs

using DataFrames
import EDFPlus


include("Basics.jl")
include("electrodes.jl")
include("EEGData.jl")
include("fileio/loadedf.jl")

include("entropy/pentropy.jl")




end #module
