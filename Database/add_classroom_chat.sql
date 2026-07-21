USE CloudPhoria;
GO

-- Classroom Messages table for real-time-style chat within classrooms
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ClassroomMessages')
BEGIN
    CREATE TABLE ClassroomMessages (
        MessageID       INT IDENTITY(1,1) PRIMARY KEY,
        ClassroomID     INT NOT NULL,
        SenderID        INT NOT NULL,
        MessageText     NVARCHAR(2000) NOT NULL,
        SentAt          DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_ClassroomMessages_Classroom FOREIGN KEY (ClassroomID) REFERENCES Classrooms(ClassroomID),
        CONSTRAINT FK_ClassroomMessages_Sender FOREIGN KEY (SenderID) REFERENCES Users(UserID)
    );

    CREATE INDEX IX_ClassroomMessages_ClassroomID_SentAt
        ON ClassroomMessages (ClassroomID, SentAt DESC);
END
GO
