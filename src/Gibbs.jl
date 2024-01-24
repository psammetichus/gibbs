module Gibbs

export  Electrode, whichSide, ifcn_electrodes,
        Signal, RMat, spectralEdge,
        saveAsJLD, loadJLD,
        Annotation, EEG, EEGFrame, convertToDataFrame, getSignal,
        loadEEGFromEDF, loadEEGFromJLD, convertDirectory!,
        dataFirFilter, eegFirFilter!, dataIirFilter, eegIirFilter!,
        emd, hilbertHuang,
        eegSegment, eegFilter, eegStandardize!, eegRectify!,
        findSymbol, pentropy,
        sobi

include("basics/Basics.jl")
include("basics/electrodes.jl")
include("basics/EEGData.jl")
include("bss/sobi.jl")
include("fileio/eegJLD.jl")
include("fileio/loadedf.jl")
include("transforms/filter.jl")
include("entropy/pentropy.jl")
include("transforms/hilbertHuang.jl")



end #module
