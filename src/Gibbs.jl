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
