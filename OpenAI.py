import json
from openai import OpenAI

# Ініціалізація клієнта OpenAI
client = OpenAI()

# Шлях до JSON-файлу
json_file_path = "sentences.json"

# Шлях до файлу з результатами
output_file_path = "GPT_results.txt"

try:
    with open(json_file_path, "r", encoding="utf-8") as file:
        sentences = json.load(file)

    # Список моделей для використання
    models = ["gpt-3.5-turbo", "gpt-3.5-turbo-16k", "gpt-4"]

    # Відкриття файлу для запису результатів
    with open(output_file_path, "w", encoding="utf-8") as output_file:
        
        # Обробка кожного речення
        for idx, sentence_data in enumerate(sentences, 1):
            sentence = sentence_data.get("sentence", "")
            if "[MASK]" not in sentence:
                output_file.write(f"Пропущено: {sentence} (немає [MASK])\n")
                print(f"Речення №{idx}: Пропущено")
                continue

            # Виклик моделей
            for model in models:
                try:
                    completion = client.chat.completions.create(
                        model=model,
                        messages=[
                            {"role": "system", "content": "You are a helpful Hebrew assistant."},
                            {"role": "user", "content": f"Give 5 variants for the word that should replace [MASK]: {sentence}"}
                        ]
                    )

                    # Отримання результату
                    response_content = completion.choices[0].message.content

                    # Запис у файл
                    output_file.write(f"Модель: {model}\n")
                    output_file.write(f"Речення: {sentence}\n")
                    output_file.write(response_content + "\n")
                    output_file.write("-" * 50 + "\n")

                    # Вивід номера на екран
                    print(f"Речення №{idx}: Оброблено моделлю {model}")

                except Exception as e:
                    output_file.write(f"Модель: {model} - Помилка: {str(e)}\n")
                    output_file.write("-" * 50 + "\n")
                    print(f"Речення №{idx}: Помилка моделлю {model}")

except FileNotFoundError:
    print(f"Файл {json_file_path} не знайдено.")
except json.JSONDecodeError:
    print("Помилка при обробці JSON-файлу.")
