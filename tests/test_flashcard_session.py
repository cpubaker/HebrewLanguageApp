import random
import unittest
from unittest.mock import patch

import test_support

from application.flashcard_session import FlashcardSession


class FlashcardSessionTests(unittest.TestCase):
    def test_next_card_avoids_repeating_same_word_when_possible(self):
        words = [
            {"hebrew": "איש", "english": "man", "transcription": "ish"},
            {"hebrew": "אישה", "english": "woman", "transcription": "isha"},
        ]
        session = FlashcardSession(words, rng=random.Random(2))

        first_card = session.next_card()
        second_card = session.next_card()

        self.assertIsNotNone(first_card)
        self.assertIsNotNone(second_card)
        self.assertIsNot(first_card["word"], second_card["word"])

    def test_next_card_rotates_contexts_when_multiple_exist(self):
        word = {
            "_word_id": "word_dog",
            "hebrew": "כלב",
            "english": "dog",
            "transcription": "kelev",
            "_contexts": [
                {"id": "ctx_1", "hebrew": "כלב אחד", "translation": "One dog"},
                {"id": "ctx_2", "hebrew": "כלב שני", "translation": "Second dog"},
            ],
        }
        session = FlashcardSession([word], rng=random.Random(4))

        first_card = session.next_card()
        second_card = session.next_card()

        self.assertNotEqual(first_card["context"]["id"], second_card["context"]["id"])

    @patch("application.flashcard_session.datetime")
    def test_answer_card_updates_known_counts(self, datetime_mock):
        datetime_mock.now.return_value.isoformat.return_value = "2026-03-25T11:15:00"
        word = {"hebrew": "איש", "english": "man", "transcription": "ish"}
        session = FlashcardSession([word])
        session.current_word = word

        result = session.answer_card(True)

        self.assertTrue(result["known"])
        self.assertEqual(word["correct"], 1)
        self.assertEqual(word["last_correct"], "2026-03-25T11:15:00")


if __name__ == "__main__":
    unittest.main()
