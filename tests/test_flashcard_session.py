import random
import unittest
from unittest.mock import patch

import test_support

from application.flashcard_session import FlashcardSession
from domain.models import ContextSentence, Word


class FlashcardSessionTests(unittest.TestCase):
    def test_next_card_avoids_repeating_same_word_when_possible(self):
        words = [
            {"hebrew": "ish", "english": "man", "transcription": "ish"},
            {"hebrew": "isha", "english": "woman", "transcription": "isha"},
        ]
        session = FlashcardSession(words, rng=random.Random(2))

        first_card = session.next_card()
        second_card = session.next_card()

        self.assertIsNotNone(first_card)
        self.assertIsNotNone(second_card)
        self.assertIsInstance(session.words[0], Word)
        self.assertIsNot(first_card["word"], second_card["word"])

    def test_next_card_rotates_contexts_when_multiple_exist(self):
        word = {
            "_word_id": "word_dog",
            "hebrew": "kelev",
            "english": "dog",
            "transcription": "kelev",
            "_contexts": [
                {"id": "ctx_1", "hebrew": "dog one", "translation": "One dog"},
                {"id": "ctx_2", "hebrew": "dog two", "translation": "Second dog"},
            ],
        }
        session = FlashcardSession([word], rng=random.Random(4))

        first_card = session.next_card()
        second_card = session.next_card()

        self.assertIsInstance(first_card["context"], ContextSentence)
        self.assertNotEqual(first_card["context"]["id"], second_card["context"]["id"])

    @patch("application.flashcard_session.datetime")
    def test_answer_card_updates_known_counts(self, datetime_mock):
        datetime_mock.now.return_value.isoformat.return_value = "2026-03-25T11:15:00"
        session = FlashcardSession(
            [{"hebrew": "ish", "english": "man", "transcription": "ish"}]
        )
        session.current_word = session.words[0]

        result = session.answer_card(True)

        self.assertTrue(result["known"])
        self.assertEqual(session.words[0]["correct"], 1)
        self.assertEqual(session.words[0]["last_correct"], "2026-03-25T11:15:00")

    def test_current_word_stats_returns_word_progress_snapshot(self):
        session = FlashcardSession(
            [
                {
                    "hebrew": "ish",
                    "english": "man",
                    "transcription": "ish",
                    "correct": 2,
                    "wrong": 1,
                    "last_correct": "2026-03-25T11:15:00",
                }
            ]
        )
        session.current_word = session.words[0]

        self.assertEqual(
            session.current_word_stats(),
            {
                "correct": 2,
                "wrong": 1,
                "total": 3,
                "last_correct": "2026-03-25T11:15:00",
            },
        )


if __name__ == "__main__":
    unittest.main()
