from transformers import pipeline

# Завантажуємо модель T5
model_name = "google/t5-small"

# Налаштовуємо пайплайн генерації тексту
t5 = pipeline("text2text-generation", model=model_name)

# Приклад для генерації тексту
prompt = "Translate this sentence to Hebrew: Sasha went to the university last October. She is a good student."

# Генеруємо текст
output = t5(prompt, max_length=50)

print(f"Generated Text from {model_name}:")
print(output[0]['generated_text'])
