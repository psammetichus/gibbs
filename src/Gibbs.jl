module Gibbs

using DataFrames
import EDFPlus
using Statistics
using Logging
using LinearAlgebra

include("Basics.jl")
include("electrodes.jl")
include("EEGData.jl")

include("fileio/eegJLD.jl")
include("fileio/loadedf.jl")

include("entropy/pentropy.jl")




end #module
