function openEEGSQLite(filename :: String)
    if !isfile(filename)
        prepareStmts = read("eegfile.sql")    
        db = SQLite.DB(filename)
        DBInterface.execute(db, prepareStmts, [])
        return db
    else
        db = SQLite.DB(filename)
        return db
    end #if
end #function

function getSubjects(db :: SQLite.DB)
    return DBInterface.execute(db, """select * from Subject;""", [])
end #function

function getRecordsBySubject(db :: SQLite.DB, subjID :: Int)
    return DBInterface.execute(db,
    """select * from RecordData, RecordXSubject where
        RecordXSubject.subj = ?;""", [subjID])
end #function

function getTrodeID(db :: SQLite.DB, trodeNames :: [String])
    return DBInterface.execute(db,
    """select trodeName, trodeID from Electrodes where trodeName = ?;""", trodeNames)
end #function

function getChunksFromTrode(db ::SQLite.DB, recID :: Int, trodeID :: Int)
    DBInterface.execute(db, """select offset, blobsamples, signaldata from
                                Chunks where record = ? and trodeID = ?
                                order by offset;""", [recID, trodeID])
end #function

function getAnnotationsByRecord(db :: SQLite.DB, recID :: Int)
    DBInterface.execute(db,
    """select annotID, onset, duration, name, desc from Annotations where
        recID = ?;""", [recID])
end #function

function saveEEGToSQL(eeg, db, trodes, subj :: Subject)
    chunkSize = 2^9
    l = eeg.length
    #not sure how to get the autoincremented ID
    newSubj = DBInterface.execute(db,
    """insert into Subject(age, gender) values(?,?);""", (subj.age, subj.gender))
    subjID = newSubj[1]
    newRecord = DBInterface.execute(db,
    """insert into RecordData(fs) values(?);""", (eeg.Fs,)) |> collect
    recID = newRecord[1]
    DBInterface.execute(db,
    """insert into RecordXSubject(subj, record) values(?,?);""", (subjID, recID))
    for (trode, data) ∈ eeg.signals
        trodeID = trodes[trode]
        for i ∈ 1:chunkSize:l  
            DBInterface.execute(db, 
            """insert into Chunks(record, trodeID, offset, blobSamples, signaldata
            values(?,?,?,?,?);""", 
            (recID, trodeID, i-1, chunkSize, data[i:chunkSize+i]))
        end #for
    end #for
end #function

