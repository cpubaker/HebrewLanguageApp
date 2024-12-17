CREATE DATABASE HebrewLearningDB;
GO
USE HebrewLearningDB;
GO
CREATE TABLE PartOfSpeech (
    part_of_speech_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL
);
CREATE TABLE Gender (
    gender_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(50) NOT NULL
);
CREATE TABLE Roots (
    root_id INT PRIMARY KEY IDENTITY(1,1),
    root NVARCHAR(100) NOT NULL
);
CREATE TABLE Binyanim (
    binyan_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL
);
CREATE TABLE Smikhut (
    smikhut_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL
);
CREATE TABLE Words (
    word_id INT PRIMARY KEY IDENTITY(1,1),
    hebrew_word NVARCHAR(100) NOT NULL,
    transcription NVARCHAR(100),
	part_of_speech_id INT FOREIGN KEY REFERENCES PartOfSpeech(part_of_speech_id),
    gender_id INT FOREIGN KEY REFERENCES Gender(gender_id),
    root_id INT FOREIGN KEY REFERENCES Roots(root_id),
    binyan_id INT FOREIGN KEY REFERENCES Binyanim(binyan_id),
    smikhut_id INT FOREIGN KEY REFERENCES Smikhut(smikhut_id),
    difficulty_level INT,
    example_sentence NVARCHAR(500),
    date_added DATETIME DEFAULT GETDATE()
);
CREATE TABLE Attempts (
    attempt_id INT PRIMARY KEY IDENTITY(1,1),
    word_id INT FOREIGN KEY REFERENCES Words(word_id),
    result NVARCHAR(50) NOT NULL,
    attempt_date DATETIME DEFAULT GETDATE(),
    attempt_count INT
);
CREATE TABLE Translations (
    translation_id INT PRIMARY KEY IDENTITY(1,1),
    word_id INT FOREIGN KEY REFERENCES Words(word_id),
    translation NVARCHAR(200) NOT NULL
);
