import json
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

# Ініціалізація моделі DictaLM 2.0
model = AutoModelForCausalLM.from_pretrained(
    'dicta-il/dictalm2.0', 
    torch_dtype=torch.float16, 
    device_map='cuda'  # Використання GPU
)
tokenizer = AutoTokenizer.from_pretrained('dicta-il/dictalm2.0')

# Перевірка доступності GPU
if not torch.cuda.is_available():
    print("Попередження: CUDA недоступний. Модель працюватиме на CPU.")

# Шляхи до файлів
json_file_path = "Test_sentences.json"
output_file_path = "DictaLM2_results.txt"

try:
    # Завантаження JSON-файлу
    with open(json_file_path, "r", encoding="utf-8") as file:
        sentences = json.load(file)

    # Відкриття файлу для запису результатів
    with open(output_file_path, "w", encoding="utf-8") as output_file:
        # Обробка кожного речення
        for sentence_data in sentences:
            sentence = sentence_data.get("sentence", "")

            # Перевірка наявності [MASK]
            if "[MASK]" not in sentence:
                output_file.write(f"Пропущено: {sentence} (немає [MASK])\n")
                print(f"Пропущено: {sentence} (немає [MASK])")
                continue

            # Перетворення речення: видалення [MASK]
            prompt = sentence.replace("[MASK]", "").strip()

            # Генерація тексту
            try:
                encoded_input = tokenizer(prompt, return_tensors='pt').to(model.device)
                generated_output = model.generate(
                    **encoded_input, 
                    max_new_tokens=50,  # Обмеження на кількість нових токенів
                    do_sample=False,  # Детермінований вивід
                    top_k=50,  # Обмеження на найкращі варіанти
                    top_p=0.9  # Вибір токенів з сумарною ймовірністю 90%
                )

                # Декодування результату
                decoded_output = tokenizer.decode(generated_output[0], skip_special_tokens=True)

                # Запис результату в файл та вивід на екран
                print(f"Речення (prompt): {prompt}")
                print("Згенерований текст:")
                print(decoded_output)
                print("-" * 50)

                output_file.write(f"Речення (prompt): {prompt}\n")
                output_file.write("Згенерований текст:\n")
                output_file.write(f"{decoded_output}\n")
                output_file.write("-" * 50 + "\n")

            except Exception as e:
                print(f"Помилка під час обробки речення: {prompt} - {str(e)}")
                output_file.write(f"Помилка під час обробки речення: {prompt} - {str(e)}\n")
                output_file.write("-" * 50 + "\n")

except FileNotFoundError:
    print(f"Файл {json_file_path} не знайдено.")
except json.JSONDecodeError:
    print("Помилка під час обробки JSON-файлу.")
