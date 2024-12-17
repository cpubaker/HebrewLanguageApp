CREATE PROCEDURE AddWord
    @HebrewWord NVARCHAR(50),
    @PartOfSpeechId INT,
    @GenderId INT = NULL,
    @Translation NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @WordId INT;

    -- Додавання слова у таблицю Words
    INSERT INTO Words (hebrew_word, part_of_speech_id, gender_id)
    OUTPUT INSERTED.word_id INTO @WordId
    VALUES (@HebrewWord, @PartOfSpeechId, @GenderId);

    -- Додавання перекладу у таблицю Translations
    INSERT INTO Translations (word_id, translation)
    VALUES (@WordId, @Translation);

    PRINT 'Слово успішно додано з ID: ' + CAST(@WordId AS NVARCHAR(10));
END
GO

CREATE PROCEDURE UpdateWord
    @WordId INT,
    @HebrewWord NVARCHAR(50),
    @PartOfSpeechId INT,
    @GenderId INT = NULL,
    @Translation NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Оновлення слова
    UPDATE Words
    SET hebrew_word = @HebrewWord,
        part_of_speech_id = @PartOfSpeechId,
        gender_id = @GenderId
    WHERE word_id = @WordId;

    -- Оновлення перекладу
    UPDATE Translations
    SET translation = @Translation
    WHERE word_id = @WordId;

    PRINT 'Слово успішно оновлено.';
END
GO

CREATE PROCEDURE GetUserStatistics
AS
BEGIN
    SET NOCOUNT ON;

    SELECT W.hebrew_word, 
           COUNT(A.attempt_id) AS total_attempts,
           SUM(CASE WHEN A.result = 'успіх' THEN 1 ELSE 0 END) AS successful_attempts,
           CAST(SUM(CASE WHEN A.result = 'успіх' THEN 1 ELSE 0 END) * 100.0 / COUNT(A.attempt_id) AS DECIMAL(5,2)) AS success_rate
    FROM Words W
    JOIN Attempts A ON W.word_id = A.word_id
    GROUP BY W.hebrew_word
    ORDER BY success_rate DESC;
END
GO

CREATE PROCEDURE DeleteWord
    @WordId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Видалення перекладів
    DELETE FROM Translations WHERE word_id = @WordId;

    -- Видалення слова
    DELETE FROM Words WHERE word_id = @WordId;

    PRINT 'Слово успішно видалено.';
END

CREATE PROCEDURE AddAttempt
    @WordId INT,
    @Result NVARCHAR(10),
    @AttemptCount INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Attempts (word_id, result, attempt_date, attempt_count)
    VALUES (@WordId, @Result, GETDATE(), @AttemptCount);

    PRINT 'Результат вправи успішно додано.';
END
