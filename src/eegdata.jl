using SQLite
using DataFrames

function openEegFile(file :: String) :: DB
  db = DB(file)
  return db
end

function getChunk(db :: DB, record :: Int, lead :: Int, offset :: Int) Vector{Float32}

  df = DBInterface.execute(db, """select * from Chunks where record = ?, offset = ?, trodeId = ?""",
                            [record, offset, lead]) |> DataFrame
  
  return df[signalData]
end

function closeEegFile(db :: DB)
  #is there no close function?
end

