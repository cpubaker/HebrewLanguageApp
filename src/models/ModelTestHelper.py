import os
import json
import torch
from transformers import AutoModelForMaskedLM, AutoTokenizer, pipeline
from openai import OpenAI


class ModelTestHelper:
    def __init__(self, model_name, output_file_path, use_pipeline=False, trust_remote_code=False, use_openai=False):
        self.use_openai = use_openai

        if use_openai:
            self.client = OpenAI()
            self.models = ["gpt-3.5-turbo", "gpt-3.5-turbo-16k", "gpt-4"]
        else:
            self.tokenizer = AutoTokenizer.from_pretrained(model_name)
            self.model = AutoModelForMaskedLM.from_pretrained(model_name, trust_remote_code=trust_remote_code)
            if use_pipeline:
                self.fill_mask = pipeline("fill-mask", model=self.model, tokenizer=self.tokenizer)

        self.output_file_path = output_file_path
        self.use_pipeline = use_pipeline

    def run_test(self, json_file_path=None, max_sentences=None):
        sentences = []

        if json_file_path:
            try:
                with open(json_file_path, "r", encoding="utf-8") as file:
                    sentences = json.load(file)
                if max_sentences:
                    sentences = sentences[:max_sentences]
            except FileNotFoundError:
                print(f"Файл {json_file_path} не знайдено.")
                return
            except json.JSONDecodeError:
                print("Помилка під час обробки JSON-файлу.")
                return

        if not sentences:
            print("Немає речень для обробки.")
            return

        with open(self.output_file_path, "w", encoding="utf-8") as output_file:
            for idx, sentence_data in enumerate(sentences, 1):
                sentence = sentence_data.get("sentence", "") if isinstance(sentence_data, dict) else sentence_data

                if "[MASK]" not in sentence:
                    self._log(f"Пропущено: {sentence} (немає [MASK])", output_file)
                    continue

                try:
                    if self.use_openai:
                        # Виклик OpenAI моделей
                        for model in self.models:
                            completion = self.client.chat.completions.create(
                                model=model,
                                messages=[
                                    {"role": "system", "content": "You are a helpful Hebrew assistant."},
                                    {"role": "user", "content": f"Give 5 variants for the word that should replace [MASK]: {sentence}"}
                                ]
                            )

                            response_content = completion.choices[0].message.content
                            self._log(f"Модель: {model}", output_file)
                            self._log(f"Речення: {sentence}", output_file)
                            self._log(response_content, output_file)
                            self._log("-" * 50, output_file)

                            print(f"Речення №{idx}: Оброблено моделлю {model}")

                    elif self.use_pipeline:
                        # Використання пайплайну
                        results = self.fill_mask(sentence)
                        self._log(f"Речення: {sentence}", output_file)
                        self._log("Топ-5 передбачень:", output_file)
                        for prediction in results[:5]:
                            token_str = prediction['token_str']
                            score = prediction['score']
                            self._log(f"Токен: {token_str} | Ймовірність: {score:.4f}", output_file)

                    else:
                        # Використання моделі без пайплайну
                        input_ids = self.tokenizer.encode(sentence, return_tensors="pt")
                        mask_token_index = torch.where(input_ids == self.tokenizer.mask_token_id)[1]
                        token_logits = self.model(input_ids).logits
                        mask_token_logits = token_logits[0, mask_token_index, :]
                        top_5_tokens = torch.topk(mask_token_logits, 5, dim=1).indices[0].tolist()

                        self._log(f"Речення: {sentence}", output_file)
                        self._log("Топ-5 передбачень:", output_file)
                        for token in top_5_tokens:
                            predicted_word = self.tokenizer.decode([token])
                            completed_sentence = sentence.replace("[MASK]", predicted_word)
                            self._log(completed_sentence, output_file)

                    self._log("-" * 50, output_file)

                except Exception as e:
                    self._log(f"Помилка під час обробки речення: {sentence} - {str(e)}", output_file)
                    self._log("-" * 50, output_file)

    def _log(self, message, output_file):
        print(message)
        output_file.write(message + "\n")


# Створення шляхів для папок
base_folder = os.path.abspath("data")
input_folder = os.path.join(base_folder, "input")
output_folder = os.path.join(base_folder, "output")

# Створення папок, якщо вони відсутні
os.makedirs(input_folder, exist_ok=True)
os.makedirs(output_folder, exist_ok=True)

# Запуск тестів

# DictaBERT
dictabert_model = ModelTestHelper(
    model_name="dicta-il/dictabert",
    output_file_path=os.path.join(output_folder, "DictaBert_results.txt")
)
dictabert_model.run_test(json_file_path=os.path.join(input_folder, "Test_sentences.json"), max_sentences=10)

# AlephBERT-Gimmel
alephbert_model = ModelTestHelper(
    model_name="imvladikon/alephbertgimmel-base-512",
    output_file_path=os.path.join(output_folder, "AlephBert_results.txt")
)
alephbert_model.run_test(json_file_path=os.path.join(input_folder, "Test_sentences.json"), max_sentences=10)

# HeBERT
heber_model = ModelTestHelper(
    model_name="avichr/heBERT",
    output_file_path=os.path.join(output_folder, "HeBert_results.txt"),
    use_pipeline=True,
    trust_remote_code=True
)
heber_model.run_test(json_file_path=os.path.join(input_folder, "Test_sentences.json"), max_sentences=10)

# OpenAI GPT
openai_model = ModelTestHelper(
    model_name="openai",
    output_file_path=os.path.join(output_folder, "GPT_results.txt"),
    use_openai=True
)
openai_model.run_test(json_file_path=os.path.join(input_folder, "Test_sentences.json"), max_sentences=10)
