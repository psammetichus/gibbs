create table Chunks (
      chunkid integer primary key autoincrement,
      record integer references RecordData(recordId) on delete cascade,
      trodeID integer,
      offset integer,
      blobSamples integer,
      signaldata blob 
);

create table RecordData (
      recordId integer primary key autoincrement,
      age integer,
      fs real
);

