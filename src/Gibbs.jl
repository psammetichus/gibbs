module Gibbs


using DSP
using FFTW
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
using GLM
using Base.Threads


@info "loading basic electrode data..."
include("basics/electrodes.jl")
export ifcn_electrodes, Electrode, whichSide

@info "loading EEG struct data and supporting routines..."
include("basics/EEGData.jl")
export Annotation, EEG, EEGFrame, convertToDataFrame, getSignal, putSignal!, signalCount,
       getSignalDiff, getSignalAvg, getSignalRefF, filterSignal!, linearComboSignal,
       getAnnotationByNum, findAnnotations, addAnnotation!, AnnotationGroup, EegGroup, freqBands,
       fourierFreqs, freqBand

@info "loading misc routines..."
include("analysis/misc.jl")
export spectralEdge, lineLength, lineLengthNorm

@info "loading SOBI..."
include("analysis/sobi.jl")
export sobi

@info "loading fractal dimension methods..."
include("analysis/fractaldimension.jl")
export katzFD, higuchiFD

@info "loading IO for JLD files..."
include("fileio/eegJLD.jl")
export saveAsJLD, loadJLD

@info "loading IO for EDF files..."
include("fileio/loadedf.jl")
export loadEEGFromEDF, loadEEGFromJLD, convertDirectory!

@info "loading exporter for BacAv..."
include("fileio/bacav.jl")
export exportBacAv

@info "loading filter methods..."
include("transforms/filter.jl")
export eegFirFilter!, eegIirFilter!, eegFirFilter, eegIirFilter, notch

@info "loading permutation entropy method..."
include("analysis/pentropy.jl")
export findSymbol, pentropy

@info "loading average reference routines..."
include("basics/average.jl")
export makeAvgRef, makeAvgRef!

@info "loading Hilbert-Huang transform..."
include("transforms/hilbertHuang.jl")
export emd, hilbertHuang

@info "loading IO for CSV..."
include("fileio/eegcsv.jl")
export loadEEGFrameFromCSV, saveEEGFrameAsCSV

#include("fooof/fooof.jl")


end #module
