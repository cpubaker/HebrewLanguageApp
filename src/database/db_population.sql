USE HebrewLearningDB;
GO

-- Заповнення таблиці Binyanim (усі біньяни)
INSERT INTO Binyanim (name) VALUES 
(N"פָּעַל"),   -- Пааль (Pa'al)
(N"נִפְעַל"), -- Ніф'аль (Nif'al)
(N"פִּעֵל"),   -- Піель (Pi'el)
(N"פּוּעַל"), -- Пуаль (Pual)
(N"הִפְעִיל"), -- Хіф'іль (Hif'il)
(N"הָפְעַל"), -- Хуф'аль (Huf'al)
(N"הִתְפַּעֵל"); -- Гітпаель (Hitpa'el)

-- Заповнення таблиці Roots (десять коренів)
INSERT INTO Roots (root) VALUES 
(N"א.כ.ל"), -- їсти
(N"ל.מ.ד"), -- вчитися
(N"ש.מ.ר"), -- охороняти
(N"ד.ב.ר"), -- говорити
(N"ע.ב.ד"), -- працювати
(N"י.ש.ב"), -- сидіти
(N"ק.ר.א"), -- читати
(N"ב.נ.ה"), -- будувати
(N"מ.צ.א"), -- знаходити
(N"ג.ד.ל"); -- рости

-- Заповнення таблиці Words (десять слів з прикладами)
INSERT INTO Words (hebrew_word, transcription, gender_id, root_id, binyan_id, smikhut_id, difficulty_level, example_sentence)
VALUES 
(N"אֹכֵל", N"אֹכֵל", 1, 1, 1, 1, 1, N"הַיֶּלֶד אֹכֵל לֶחֶם"),  -- Їсть
(N"לָמַד", N"לָמַד", 1, 2, 1, 1, 2, N"הוּא לָמַד עִבְרִית"),  -- Вчився
(N"שׁוֹמֵר", N"שׁוֹמֵר", 1, 3, 1, 1, 2, N"הַשּׁוֹמֵר שׁוֹמֵר עַל הַגַּן"), -- Охороняє
(N"דִּבֵּר", N"דִּבֵּר", 1, 4, 3, 1, 3, N"הוּא דִּבֵּר אִתִּי"),  -- Говорив
(N"עָבַד", N"עָבַד", 1, 5, 1, 1, 1, N"הוּא עָבַד בַּשָּׂדֶה"), -- Працював
(N"יָשַׁב", N"יָשַׁב", 1, 6, 1, 1, 2, N"הוּא יָשַׁב עַל הַכִּסֵּא"), -- Сидів
(N"קָרָא", N"קָרָא", 1, 7, 1, 1, 2, N"הוּא קָרָא סֵפֶר"), -- Читав
(N"בָּנָה", N"בָּנָה", 1, 8, 5, 1, 3, N"הוּא בָּנָה בַּיִת"), -- Будував
(N"מָצָא", N"מָצָא", 1, 9, 1, 1, 2, N"הוּא מָצָא אֶת הַמַּפְתֵּחַ"), -- Знайшов
(N"גָּדַל", N"גָּדַל", 1, 10, 1, 1, 2, N"הוּא גָּדַל בִּירוּשָׁלַיִם"); -- Ріс

-- Заповнення таблиці Translations (переклади слів)
INSERT INTO Translations (word_id, translation) VALUES 
(1, N"їсти"), 
(2, N"вчитися"), 
(3, N"охороняти"), 
(4, N"говорити"), 
(5, N"працювати"), 
(6, N"сидіти"), 
(7, N"читати"), 
(8, N"будувати"), 
(9, N"знаходити"), 
(10, N"рости");

-- Заповнення таблиці Attempts (спроби використання слів)
INSERT INTO Attempts (word_id, result, attempt_date, attempt_count) VALUES 
(1, N"Успіх", GETDATE(), 1),
(2, N"Помилка", GETDATE(), 2),
(3, N"Успіх", GETDATE(), 1),
(4, N"Помилка", GETDATE(), 3),
(5, N"Успіх", GETDATE(), 1),
(6, N"Помилка", GETDATE(), 2),
(7, N"Успіх", GETDATE(), 1),
(8, N"Помилка", GETDATE(), 2),
(9, N"Успіх", GETDATE(), 1),
(10, N"Помилка", GETDATE(), 2);