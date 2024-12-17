import pyodbc

class DatabaseManager:
    def __init__(self, config):
        self.conn = pyodbc.connect(
            f"Driver={{ODBC Driver 17 for SQL Server}};"
            f"Server={config['SERVER']};"
            f"Database={config['DATABASE']};"
            f"UID={config['USERNAME']};"
            f"PWD={config['PASSWORD']};"
        )
        self.cursor = self.conn.cursor()

    def add_word(self, hebrew_word, part_of_speech_id, gender_id, translation):
        """Викликає збережену процедуру AddWord"""
        try:
            self.cursor.execute(
                "{CALL AddWord (?, ?, ?, ?)}",
                hebrew_word, part_of_speech_id, gender_id, translation
            )
            self.conn.commit()
            print("Слово успішно додано.")
        except Exception as e:
            print(f"Помилка під час додавання слова: {e}")

    def update_word(self, word_id, hebrew_word, part_of_speech_id, gender_id, translation):
        """Викликає збережену процедуру UpdateWord"""
        try:
            self.cursor.execute(
                "{CALL UpdateWord (?, ?, ?, ?, ?)}",
                word_id, hebrew_word, part_of_speech_id, gender_id, translation
            )
            self.conn.commit()
            print("Слово успішно оновлено.")
        except Exception as e:
            print(f"Помилка під час оновлення слова: {e}")

    def delete_word(self, word_id):
        """Викликає збережену процедуру DeleteWord"""
        try:
            self.cursor.execute(
                "{CALL DeleteWord (?)}", word_id
            )
            self.conn.commit()
            print("Слово успішно видалено.")
        except Exception as e:
            print(f"Помилка під час видалення слова: {e}")

    def add_attempt(self, word_id, result, attempt_count):
        """Викликає збережену процедуру AddAttempt"""
        try:
            self.cursor.execute(
                "{CALL AddAttempt (?, ?, ?)}",
                word_id, result, attempt_count
            )
            self.conn.commit()
            print("Результат вправи успішно додано.")
        except Exception as e:
            print(f"Помилка під час додавання результату вправи: {e}")

    def get_user_statistics(self):
        """Отримує статистику успішності користувача"""
        try:
            self.cursor.execute("{CALL GetUserStatistics}")
            results = self.cursor.fetchall()
            for row in results:
                print(f"Слово: {row.hebrew_word}, Успіх: {row.successful_attempts}, "
                      f"Всього спроб: {row.total_attempts}, Відсоток успіху: {row.success_rate}%")
        except Exception as e:
            print(f"Помилка отримання статистики: {e}")

    def close(self):
        """Закриття підключення до бази даних"""
        self.cursor.close()
        self.conn.close()
