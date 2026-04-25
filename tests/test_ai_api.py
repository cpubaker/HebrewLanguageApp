import tempfile
import unittest
from pathlib import Path

from backend.ai_api.cache import JsonDiskCache
from backend.ai_api.content import (
    RequestValidationError,
    normalize_practice_text_request,
    normalize_word_context_request,
)
from backend.ai_api.server import AiApiApplication


class AiApiApplicationTests(unittest.TestCase):
    def test_word_contexts_are_generated_and_cached(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            fake_client = FakeOpenAIClient()
            app = AiApiApplication(
                cache=JsonDiskCache(Path(temp_dir) / "cache.json"),
                openai_client=fake_client,
            )

            payload = {
                "words": [
                    {
                        "word_id": "word_book",
                        "hebrew": "ספר",
                        "translation": "книга",
                        "english": "book",
                        "transcription": "sefer",
                    }
                ]
            }

            first_response = app.handle_word_contexts(payload)
            second_response = app.handle_word_contexts(payload)

        self.assertEqual(fake_client.word_context_calls, 1)
        self.assertEqual(first_response, second_response)
        self.assertEqual(first_response["contexts"][0]["word_id"], "word_book")
        self.assertEqual(first_response["contexts"][0]["source"], "ai")
        self.assertTrue(first_response["contexts"][0]["is_new"])

    def test_practice_texts_are_generated_and_cached(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            fake_client = FakeOpenAIClient()
            app = AiApiApplication(
                cache=JsonDiskCache(Path(temp_dir) / "cache.json"),
                openai_client=fake_client,
            )

            payload = {
                "mode": "reading_practice",
                "words": [
                    {
                        "word_id": "word_house",
                        "hebrew": "בית",
                        "translation": "будинок",
                        "english": "house",
                        "transcription": "bayit",
                    }
                ],
            }

            first_response = app.handle_practice_texts(payload)
            second_response = app.handle_practice_texts(payload)

        self.assertEqual(fake_client.practice_text_calls, 1)
        self.assertEqual(first_response, second_response)
        self.assertEqual(first_response["texts"][0]["word_ids"], ["word_house"])
        self.assertEqual(first_response["texts"][0]["source"], "ai")

    def test_invalid_word_request_is_rejected(self):
        with self.assertRaises(RequestValidationError):
            normalize_word_context_request({"words": []})

    def test_practice_text_request_is_bounded(self):
        payload = {
            "max_texts": 20,
            "words": [
                {"word_id": f"word_{index}", "hebrew": "ספר"}
                for index in range(30)
            ],
        }

        normalized = normalize_practice_text_request(payload)

        self.assertEqual(normalized["max_texts"], 3)
        self.assertEqual(len(normalized["words"]), 20)


class FakeOpenAIClient:
    model = "test-model"

    def __init__(self):
        self.word_context_calls = 0
        self.practice_text_calls = 0

    def generate_word_contexts(self, request_payload):
        self.word_context_calls += 1
        return {
            "contexts": [
                {
                    "word_id": request_payload["words"][0]["word_id"],
                    "hebrew": "אני קורא ספר.",
                    "ukrainian": "Я читаю книгу.",
                }
            ]
        }

    def generate_practice_texts(self, request_payload):
        self.practice_text_calls += 1
        return {
            "texts": [
                {
                    "title": "בית קרוב",
                    "hebrew": "הבית קרוב לבית הספר.",
                    "ukrainian": "Будинок близько до школи.",
                    "word_ids": [request_payload["words"][0]["word_id"]],
                }
            ]
        }


if __name__ == "__main__":
    unittest.main()

