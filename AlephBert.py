import torch
from transformers import AutoModelForMaskedLM, AutoTokenizer

# Завантажуємо модель AlephBERT-Gimmel
model_name = "imvladikon/alephbertgimmel-base-512"
model = AutoModelForMaskedLM.from_pretrained(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)

# Наше речення для тестування
sentence = "סשה [MASK] לאוניברסיטה באוקטובר האחרון. היא תלמידה טובה."

# Токенізація та пошук токена [MASK]
input_ids = tokenizer.encode(sentence, return_tensors="pt")
mask_token_index = torch.where(input_ids == tokenizer.mask_token_id)[1]

# Логіти моделі
token_logits = model(input_ids).logits
mask_token_logits = token_logits[0, mask_token_index, :]

# Знаходимо топ-5 токенів
top_5_tokens = torch.topk(mask_token_logits, 5, dim=1).indices[0].tolist()

# Вивід результатів
print(f"Речення: {sentence}")
print("\nТоп-5 варіантів для [MASK]:")
for token in top_5_tokens:
    predicted_word = tokenizer.decode([token])
    print(f"{sentence.replace('[MASK]', predicted_word)}")
