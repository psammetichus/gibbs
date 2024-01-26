module Gibbs


include("basics/Basics.jl")
export Signal, RMat, spectralEdge

include("basics/electrodes.jl")
export ifcn_electrodes, Electrode, whichSide

include("basics/EEGData.jl")
export Annotation, EEG, EEGFrame, convertToDataFrame, getSignal

include("bss/sobi.jl")
export sobi

include("fileio/eegJLD.jl")
export saveAsJLD, loadJLD,

include("fileio/loadedf.jl")
export loadEEGFromEDF, loadEEGFromJLD, convertDirectory!

include("transforms/filter.jl")
export eegFirFilter!, eegIirFilter!

include("entropy/pentropy.jl")
export findSymbol, pentropy

include("transforms/hilbertHuang.jl")
export emd, hilbertHuang

include("fileio/eegcsv.jl")
export loadEEGFrameFromCSV, saveEEGFrameAsCSV
end #module
