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
      fs real
);

create table Subject (
      subjID integer primary key autoincrement,
      age integer,
      gender text,
);

create table RecordXSubject (
      RelID integer primary key autoincrement,
      subj integer references Subject(subjID) on delete cascade,
      record integer references RecordData(recordID) on delete cascade
);

create table Electrodes (
      trodeID integer primary key autoincrement,
      trodeName text
);

create table Annotations (
      annotID integer primary key autoincrement,
      recID integer references RecordData(recordId),
      onset real,
      duration real,
      name text,
      desc text
);