import json
from openai import OpenAI

# Ініціалізація клієнта OpenAI
client = OpenAI()

# Шлях до JSON-файлу
json_file_path = "Test_combinations.json"

# Шлях до файлу з результатами
output_file_path = "GPT_Generated_Sentences_MultiModel.txt"

# Список моделей для тестування
models = ["gpt-3.5-turbo", "gpt-3.5-turbo-16k", "gpt-4"]

try:
    # Завантаження JSON-файлу
    with open(json_file_path, "r", encoding="utf-8") as file:
        combinations = json.load(file)

    # Відкриття файлу для запису результатів
    with open(output_file_path, "w", encoding="utf-8") as output_file:

        # Обробка кожної комбінації слів
        for idx, combo_data in enumerate(combinations, 1):
            words = combo_data.get("sentence", "")

            # Генерація речень для кожної моделі
            for model in models:
                try:
                    completion = client.chat.completions.create(
                        model=model,
                        messages=[
                            {"role": "system", "content": (
                             "You are a helpful Hebrew grammar assistant. "
                            "Your task is to create meaningful, contextually appropriate, and grammatically correct Hebrew sentences "
                            "using the provided words. Ensure that the sentences are logical and relevant."
                             )},
                            {"role": "user", "content": f"Create a meaningful Hebrew sentence using these words: {words}. "
                                     "The sentence should be realistic, coherent, and free from grammatical errors."}
                        ]
                    )

                    # Отримання згенерованого тексту
                    generated_sentence = completion.choices[0].message.content

                    # Запис у файл
                    output_file.write(f"Модель: {model}\n")
                    output_file.write(f"Комбінація слів: {words}\n")
                    output_file.write(f"Згенероване речення: {generated_sentence}\n")
                    output_file.write("-" * 50 + "\n")

                    # Вивід номера на екран
                    print(f"Комбінація №{idx}, Модель {model}: Оброблено")

                except Exception as e:
                    output_file.write(f"Модель: {model}\n")
                    output_file.write(f"Комбінація слів: {words}\n")
                    output_file.write(f"Помилка: {str(e)}\n")
                    output_file.write("-" * 50 + "\n")
                    print(f"Комбінація №{idx}, Модель {model}: Помилка")

except FileNotFoundError:
    print(f"Файл {json_file_path} не знайдено.")
except json.JSONDecodeError:
    print("Помилка при обробці JSON-файлу.")
