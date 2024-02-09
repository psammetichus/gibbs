module Gibbs


using DSP
using Diagonalizations
using DataFrames
using LinearAlgebra
using Statistics
using Logging
using EDFPlus
using JLD
using Peaks
using BasicInterpolators
using CSV
using StatsBase
using LsqFit



include("basics/electrodes.jl")
export ifcn_electrodes, Electrode, whichSide

include("basics/EEGData.jl")
export Annotation, EEG, EEGFrame, convertToDataFrame, getSignal, putSignal!, signalCount,
       getSignalDiff, getSignalAvg, getSignalRefF, filterSignal!, linearComboSignal

include("analysis/misc.jl")
export spectralEdge

include("analysis/sobi.jl")
export sobi

include("fileio/eegJLD.jl")
export saveAsJLD, loadJLD

include("fileio/loadedf.jl")
export loadEEGFromEDF, loadEEGFromJLD, convertDirectory!

include("fileio/bacav.jl")
export exportTSV

include("transforms/filter.jl")
export eegFirFilter!, eegIirFilter!, eegFirFilter, eegIirFilter, notch

include("analysis/pentropy.jl")
export findSymbol, pentropy

include("basics/average.jl")
export makeAvgRef, makeAvgRef!

include("transforms/hilbertHuang.jl")
export emd, hilbertHuang

include("fileio/eegcsv.jl")
export loadEEGFrameFromCSV, saveEEGFrameAsCSV

#include("fooof/fooof.jl")


end #module
