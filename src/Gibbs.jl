module Gibbs

using DataFrames
import EDFPlus
using Statistics
using Logging
using LinearAlgebra

include("Basics.jl")
include("electrodes.jl")
include("EEGData.jl")
include("bss/sobi.jl")
include("fileio/eegJLD.jl")
include("fileio/loadedf.jl")
include("filter.jl")
include("entropy/pentropy.jl")
include("hilbertHuang.jl")
include("bss/sobi.jl")



end #module
