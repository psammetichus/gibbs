# Copyright 2022–2025 Tyson Burghardt MD FAES
# Released under GPLv3


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
using Wavelets
using EntropyHub
using OrdinaryDiffEq
using Random
using Distributions
using Match
using Dates
using SlurmClusterManager


@info "loading basic electrode data..."
include("basics/electrodes.jl")
export ifcn_electrodes, Electrode, whichSide

@info "loading EEG struct data and supporting routines..."
include("basics/EEGData.jl")
export Annotation, EEG, EEGFrame, convertToDataFrame, getSignal, putSignal!, signalCount,
       getSignalDiff, getSignalAvg, getSignalRefF, filterSignal!, linearComboSignal,
       getAnnotationByNum, findAnnotations, addAnnotation!, AnnotationGroup, EegGroup, freqBands,
       fourierFreqs, freqBand, getRawSignalData

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
export loadEEGFromEDF, convertDirectory!

@info "loading exporter for BacAv..."
include("fileio/bacav.jl")
export exportBacAv

@info "loading filter methods..."
include("transforms/filter.jl")
export eegFirFilter!, eegIirFilter!, eegFirFilter, eegIirFilter, notch

@info "loading pipeline methods"
include("transforms/pipeline.jl")
export eegSegment, zeroExtend, eegFilter, eegStandardize!, eegRectify!

@info "loading entropy routines"
include("analysis/entropy.jl")
export spectralEntropy, waveletEntropy, pentropy

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
#export FOOOF

#include("microstate/microstate.jl")

#include("dmf/fastmdf.jl")
#export runDMF

@info "loading DFA..."
include("analysis/dfa.jl")
export dfa

@info "loading Hjorth parameters..."
include("analysis/hjorth.jl")
export hjorthActivity, hjorthMobility, hjorthComplexity

@info "loading Epileptor model..."
include("models/epileptor.jl")
export runEpileptor

end #module
