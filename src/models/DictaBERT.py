import json
from transformers import AutoTokenizer, AutoModelForMaskedLM, pipeline

# Ініціалізація моделі DictaBERT
model_name = "dicta-il/dictabert"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForMaskedLM.from_pretrained(model_name)

# Створення пайплайну
fill_mask = pipeline(
    "fill-mask",
    model=model,
    tokenizer=tokenizer
)

# Шлях до JSON-файлу та файлу результатів
json_file_path = "Test_sentences.json"
output_file_path = "DictaBert_results.txt"

try:
    # Завантаження JSON-файлу
    with open(json_file_path, "r", encoding="utf-8") as file:
        sentences = json.load(file)

    # Відкриття файлу для запису результатів
    with open(output_file_path, "w", encoding="utf-8") as output_file:
        # Обробка речень з JSON-файлу
        for sentence_data in sentences:
            sentence = sentence_data.get("sentence", "")
            if "[MASK]" not in sentence:
                print(f"Пропущено: {sentence} (немає [MASK])")
                output_file.write(f"Пропущено: {sentence} (немає [MASK])\n")
                continue

            # Отримання передбачень
            try:
                result = fill_mask(sentence)
                print(f"Речення: {sentence}")
                output_file.write(f"Речення: {sentence}\n")
                print("Топ-5 передбачень:")
                output_file.write("Топ-5 передбачень:\n")

                for prediction in result[:5]:
                    token_str = prediction['token_str']
                    score = prediction['score']
                    print(f"Токен: {token_str} | Ймовірність: {score:.4f}")
                    output_file.write(f"Токен: {token_str} | Ймовірність: {score:.4f}\n")

                print("-" * 50)
                output_file.write("-" * 50 + "\n")

            except Exception as e:
                print(f"Помилка під час обробки речення: {sentence} - {str(e)}")
                output_file.write(f"Помилка під час обробки речення: {sentence} - {str(e)}\n")
                print("-" * 50)
                output_file.write("-" * 50 + "\n")

except FileNotFoundError:
    print(f"Файл {json_file_path} не знайдено.")
except json.JSONDecodeError:
    print("Помилка під час обробки JSON-файлу.")
