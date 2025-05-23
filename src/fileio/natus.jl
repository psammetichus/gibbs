#--------------------------------------------------------------------------
#
#   XLTEKReader
#
#   Adapted from OpenXLT MATLAB code by Jiarui Wang (jwang04@g.harvard.edu)
#   from Github https://github.com/mrjiaruiwang/OpenXLT/blob/main/Openxlt.m
#
#   Part of Gibbs
#
#   (c)2022-2025 Tyson Burghardt MD FAES
#
#   Licensed under GPLv3
#
#



struct EEGMontage
  chanLabels :: Vector{String}
  chanNumber :: Int
  mtxt :: String
end


mutable struct OpenXLT
  filenames :: OpenXLTFiles
  nDataFiles :: Int
  states :: OpenXLTState
  objs :: OpenXLTObjects
  subj :: OpenXLTSubject
end

mutable struct OpenXLTFiles
  #filenames
  script :: String
  dir :: String
  fileRoot :: String
  fileEEG :: String
  fileSTC :: String
  fileENT :: String
  fileVTC :: String
end

mutable struct OpenXLTState
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
end

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

mutable struct OpenXLTObjects
  objectEEG
  objectEEGList
  objectEEGMontage :: Union{EEGMontage, Nothing}
  objectSTC
  objectENT
  objectVTC
  objectETC
end

mutable struct OpenXLTSubject
  #information
  ID
  firstName :: String
  middleName :: String
  lastName :: String
  GUID :: String
  ageLabel
  age :: Int
  birthdateLabel
  birthdateStr :: String
  birthdate :: Date
  genderLabel
  gender
  handedness
  height
  weight
  freqSamp :: Float64
  headboxSn
  studyCreationTime :: DateTime
  studyXLCreationTime :: DateTime
  studyModificationTime :: DateTime
  studyEpochLength :: Int64
  studyWriterVersionMajor :: Int
  studyWriterVersionMinor :: Int
  studyProductVersionHigh :: Int
  studyProductVersionLow :: Int
  studyOrigStudyGUID :: String
  studyGUID :: String
  studyFileContents
end
  

#type alias
XltObj = Union{Vector,String,Dict,Pair}


function parseObj(oxlt :: OpenXLT, cur :: Int, intxt :: String) :: Tuple{OpenXLT,Int}
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
        aArray, cur = parseArray(oxlt, cur+1,intxt)
        stateType = 'a'
      end
    elseif intxt[cur] == ')'
      break
    elseif intxt[cur] == '"'
      aString, cur = parseString(oxlt, cur+1, intxt)
      stateType = 'v'
    end #ifelseif
    
    cur += 1

  end #while

  #switching

  @match stateType begin
    'o' => return aObj, cur
    'p' => return aPair, cur
    'a' => return aArray, cur
    'v' => return aString, cur
    _   => nothing
  end
   
end #function

function parseString(oxlt :: OpenXLT, cur :: Int, intxt :: String) :: Tuple{OpenXLT, Int}
  theString = ""
  while true
    if intxt[cur] == '"'
      break
    end
    theString *= intxt[cur]
    cur += 1
  end
  return theString, cur
end

function parsePair(oxlt :: OpenXLT, cur :: Int, intxt :: String) :: Tuple{Pair,Int}
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
        end #if
      end #ifelse
    elseif intxt[cur] == ','
      val, cur = parseValue(oxlt, cur+2, intxt)
      break
    elseif stateIsKey
      append!(key, intxt[cur])
    end #ifelseif
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
function parseArray(oxlt :: OpenXLT, cur::Int, intxt::String) :: Tuple{Array,Int}
  statePass = true
  outArray = []
  while statePass
    if intxt[cur] == '('
      obj,cur = parseObj(oxlt,cur+1,intxt)
      append!(outArray, obj)
    end #if
    cur += 1
  end #while
  return outArray, cur

end #parseArray

"""

  parseValue(oxlt, cur, intxt)

not sure the return value yet

"""
function parseValue(oxlt, cur::Int, intxt::String) :: Tuple{Any,Int}
  stateIsObj = false
  val = []
  valIdx = 1
  stateParen = false
  retObj = nothing
  while true
    c = intxt[cur]
    
    if c == '('
      val, cur = parseObj(oxlt, cur+1, intxt)
      stateIsObj = true
      break
    
    elseif c == ')'
      cur -= 1
      break
    
    elseif c == ',' && !stateParen
      cur -= 1
      break
    
    else
    
      if c == '"'
        stateParen = !stateParen
      end #if

      append!(val, c)
    end #ifelseif

    cur +=1

  end #while

  if stateIsObj
    retObj = val
  else
    retObj = val
  end #if

  return retObj, cur

end #parseValue


function parseMontageFromEEG(oxlt)
  if !oxlt.stateLoadedEEGMontages || null(oxlt.objectEEGMontage)
    throw(MontageNotLoadedError)
  end #if

  #wait this is fucking stupid
  hh = transcode(UInt8, "ChanNames")

  oxlt.obj.objectEEGMontage.mtxt = split(oxlt.obj.objectEEGMontage.mtxt, "0x")

end #parseMontageFromEEG



function cleanKey(oxlt, key) :: String
  key = replace(key, ' ' => "")
  key = replace(key, '@' => "")
  key = replace(key, '#' => "")
  key = replace(key, "''" => "") # I think?

  #pad names with leading zeros
  if isdigit(key[1])
    key = num*key
  end

  #matlab code does a validity check by seeing if key is a valid variable name
  #need to think about this
  
  return key
end #cleanKey


function cleanText(oxlt, intxt)
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
      end #if
    end #ifelseif
  end #for
end #cleanText


function loadEEG(oxlt)
  logBytes = 320
  idBytes = 20
  intBytes = 4

  #magic number for eeg files
  ID_EEG = [-905246832,298899349,-1610599761,-1521198300,65539]

  fEEG = open(oxlt.nameFileEEG, 'r')
  eegID = Int32.(read(fEEG, idBytes/intBytes))
  if eegID != ID_EEG
    println("file $(oxlt.nameFileEEG) doesn't have correct id")
  end
   

  #TODO

end #loadEEG


function carveF(indir, suffix)
  d = readdir(indir, join=true)
  files = filter(isfile, d)
  return findall(x => endswith(x, uppercase(suffix)), files)
end

function checkFileExists(file, suffix)
  isfile(file * suffix)
end

