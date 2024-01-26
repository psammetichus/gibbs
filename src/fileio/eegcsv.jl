using CSV
using DataFrames

function loadEEGFrameFromCSV(filename :: String)
    return EEGFrame(
        CSV.read(filename, DataFrame; delim=' '),
        DataFrame(["Annotations"]), #empty annotations dataframe
        256 #default Fs
    )
end #function

function saveEEGFrameAsCSV(filename :: String, eegframe :: EEGFrame, delim=' ')
    CSV.write(filename, eegframe; delim=delim)
end #function
