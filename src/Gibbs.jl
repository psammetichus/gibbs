module Gibbs

using DataFrames
import EDFPlus
using Statistics
using Logging
using LinearAlgebra
using DSP

include("Basics.jl")
include("EEGData.jl")
include("electrodes.jl")
include("bss/sobi.jl")
include("fileio/eegJLD.jl")
include("fileio/loadedf.jl")
include("filter.jl")
include("entropy/pentropy.jl")




end #module
