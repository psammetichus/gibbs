#--------------------------------------------------------------------------
#
#   XLTEKReader
#
#   Adapted from Openxlt MATLAB code by Jiarui Wang (jwang04@g.harvard.edu)
#
#   Usage
#
#       o = Openxlt('test/raw_data');
#       o = o.load();
#
#   Part of Gibbs
#
#   Tyson Burghardt
#
#   Licensed under GPLv3
#
#

module XLTEKReader

using Dates
using Match

mutable struct Openxlt
  #filenames
  nameScript :: String
  nameDir :: String
  nameFileRoot :: String
  nameFileEEG :: String
  nameFileSTC :: String
  nameFileENT :: String
  nameFileVTC :: String

  #numbers
  nDataFiles :: Int

  #load states
  stateLoadedEEG :: Bool
  stateLoadedEEGMontages :: Bool
  stateLoadedEEGAdmin :: Bool
  stateLoadedEEGName :: Bool
  stateLoadedEEGPersonal :: Bool
  stateLoadedSTC :: Bool
  stateLoadedENT :: Bool
  stateLoadedVTC :: Bool
  stateLoadedETC :: Vector{Bool}

  #structs
  #original matlab defs
  #% structs
  #object_eeg; % main file
  #object_eeg_list; % main file, additional properties
  #object_eeg_montage; % list of electrode labels
  #object_stc; % list of etc and erd data files
  #object_ent; % list of annotations
  #object_vtc; % list of video files
  #object_etc; % list of erd data file pointers

  objectEEG
  objectEEGList
  objectEEGMontage :: Union{EEGMontage, Nothing}
  objectSTC
  objectENT
  objectVTC
  objectETC

  #information
  subjectID
  subjectFirstName :: String
  subjectMiddleName :: String
  subjectLastName :: String
  subjectGUID :: String
  subjectAgeLabel
  subjectAge :: Int
  subjectBirthdateLabel
  subjectBirthdateStr :: String
  subjectBirthdate :: Date
  subjectGenderLabel
  subjectGender
  subjectHandedness
  subjectHeight
  subjectWeight
  subjectFreqSamp :: Float64
  subjectHeadboxSn
  subjectStudyCreationTime :: DateTime
  subjectStudyXLCreationTime :: DateTime
  subjectStudyModificationTime :: DateTime
  subjectStudyEpochLength :: Int64
  subjectStudyWriterVersionMajor :: Int
  subjectStudyWriterVersionMinor :: Int
  subjectStudyProductVersionHigh :: Int
  subjectStudyProductVersionLow :: Int
  subjectStudyOrigStudyGUID :: String
  subjectStudyGUID :: String
  subjectStudyFileContents

  #recording info
  #these are commented out?
  #timeRecordingStart :: DateTime
  #timeRecordingEnd :: DateTime
  #entCleaned


end #struct

struct EEGMontage
  chanLabels :: Vector{String}
  chanNumber :: Int
  mtxt :: String
end

#type alias
XltObj = Union{Vector,String,Dict,Pair}


function parseObj(oxlt :: Openxlt, cur :: Int, intxt :: String) :: Tuple{Openxlt,Int}
  statePass = true
  stateType :: Char = 'x' 
  while statePass
    if cur > length(intxt)
      #stop parsing at EOF
      break
    end
    
    if intxt[cur] == '('
      aObj, cur = parseObj(oxlt, cur+1, intxt)
      stateType = 'o'
    elseif intxt[cur] == '.'
      if intxt[cur+1] == '"'
        aPair, cur = parsePair(oxlt, cur+1, intxt)
        stateType = 'p'
      elseif intxt[cur+1] == '('
        aArray, cur = parseArray(cur+1,intxt)
        stateType = 'a'
      end
    elseif intxt[cur] == ')'
      break
    elseif intxt[cur] == '"'
      aString, cur = parseArray(cur, intxt)
      stateType = 'v'
    end
    
    cur += 1

  end #while

  #switching

  @match stateType begin
    'o' => return aObj, cur
    'p' => return aPair, cur
    'a' => return aArray, cur
    'v' => return String(aString), cur
    _   => nothing
  end
   
end #function


function parsePair(oxlt :: Openxlt, cur :: Int, intxt :: String) :: Tuple{Pair,Int}
  stateIsKey = false
  stateIsVal = false
  while true
    if intxt[cur] == '"'
      if !stateIsKey
        #parsing key
        stateIsKey = true
        key = ""
      else
        #end key
        stateIsKey = false
        if intxt[cur+1] == ')'
          val = nothing
          break
        end
      end
    elseif intxt[cur] == ','
      val, cur = parseValue(oxlt, cur+2, intxt)
      break
    elseif stateIsKey
      append!(key, intxt[cur])
    end
  end #while

  return (cleanKey(key) => val, cur)

end #parsePair

"""

  parseArray(oxlt, cur, intxt)

parses an array in a ckey stream

this version parses arrays of things as well as strings
but in Julia an array of chars is not the same as a string
So needs fixing

"""
function parseArray(oxlt :: Openxlt, cur::Int, intxt::String) :: Tuple{Array,Int}
  statePass = true
  outArray = []
  while statePass
    if intxt[cur] == '('
      obj,cur = parseObj(oxlt,cur+1,intxt)
      append!(outArray, obj)
      try #seems like a superfluous try block; probably needed for backtracking
        if intxt[cur+1] != ','
          break
        end
      catch
        break
      end
    elseif intxt[cur] == '"'
      obj, cur = parseObj(cursor+1,intxt)
      append!(outArray,obj)
      try
        if intxt[cur+1] != ','
          break
        end
      catch
        break
      end
    end
    cur += 1
      #array of char not the same as a string
  end
    return outArray, cur
end #parseArray

"""

  parseValue(oxlt, cur, intxt)

not sure the return value yet

"""
function parseValue(oxlt :: Openxlt, cur::Int, intxt::String) :: Tuple{Any,Int}
  stateIsObj = false
  #64 digit--supposed to be a 64bit value I think
  val = "0000000000000000000000000000000000000000000000000000000000000000" #okay...
  valIdx = 1
  stateParen = false
  retObj = nothing
  while true
    c = intxt[cur]
    if c == '('
      val, cur = parseObj(oxlt, cur+1, intxt)
      stateIsObj = true
      break
    elseif c == == ')'
      cur -= 1
      break
    elseif c == ',' && !stateParen
      cur -= 1
      break
    else
      if c == '"'
        stateParen = !stateParen
      end
      val[valIdx] = c
      valIdx += 1
    end
    cur +=1
  end

  if stateIsObj
    retObj = val
  else
    retObj = val[1:valIdx-1]
  end
  return retObj, cur

  end #while
end #parseValue


"""

  cleanKey(oxlt, key)

cleans a key
"""
function cleanKey(oxlt ::Openxlt, key :: Key) :: String
  key = replace(key, ' ' => '')
  key = replace(key, '@' => '')
  key = replace(key, '#' => '')
  key = replace(key, "''" => '') # I think?

  #pad names with leading zeros
  if isdigit(key[1])
    key = num*key
  end

  #matlab code does a validity check by seeing if key is a valid variable name
  #need to think about this
  
  return key
end #cleanKey


function cleanText(oxlt::Openxlt, intxt)
  level = 0
  stateStarted = false
  cursorStart = 1
  outcell = nothing
  for cursor in 1:length(intxt)
    current = intxt[cursor]
    if current == '('
      if level == 0
        stateStarted = true
        cursorStart = cursor
      end
      level += 1
    elseif current == ')'
      level -= 1
      if level == 0 && stateStarted
        stateStarted = false
        outcell
  end #for
end #cleanText


function parseMontageFromEEG(oxlt::Openxlt)
  if !oxlt.stateLoadedEEGMontages || null(oxlt.objectEEGMontage)
    throw MontageNotLoadedError
  end

  #wait this is fucking stupid
  hh = transcode(UInt8, "ChanNames")

  mtxt = split(oxlt.objectEEGMontage.mtxt, "0x")

end #parseMontageFromEEG


function loadEEG(oxlt::Openxlt)
  logBytes = 320
  idBytes = 20
  intBytes = 4

  #magic number for eeg files
  ID_EEG = [-905246832,298899349,-1610599761,-1521198300,65539]

  fEEG = open(oxlt.nameFileEEG, 'r')
  eegID = read(fEEG, <F5>



end #loadEEG
