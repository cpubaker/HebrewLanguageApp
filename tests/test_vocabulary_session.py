import random
import unittest
from unittest.mock import patch

import test_support

from application.vocabulary_session import VocabularySession


class VocabularySessionTests(unittest.TestCase):
    def test_next_prompt_returns_current_word_and_options(self):
        words = [
            {"hebrew": "איש", "english": "man", "transcription": "ish"},
            {"hebrew": "אישה", "english": "woman", "transcription": "isha"},
        ]
        session = VocabularySession(words, rng=random.Random(3))

        prompt = session.next_prompt()

        self.assertIsNotNone(prompt)
        self.assertIn(prompt["word"], words)
        self.assertGreaterEqual(len(prompt["options"]), 1)
        self.assertIn(prompt["word"]["english"], prompt["options"])

    @patch("application.vocabulary_session.datetime")
    def test_submit_answer_updates_correct_counts(self, datetime_mock):
        datetime_mock.now.return_value.isoformat.return_value = "2026-03-25T11:00:00"
        word = {"hebrew": "איש", "english": "man", "transcription": "ish"}
        session = VocabularySession([word], rng=random.Random(1))
        session.current_word = word

        result = session.submit_answer("man")

        self.assertTrue(result["is_correct"])
        self.assertEqual(word["correct"], 1)
        self.assertEqual(word["last_correct"], "2026-03-25T11:00:00")

    def test_submit_answer_updates_wrong_counts(self):
        word = {"hebrew": "איש", "english": "man", "transcription": "ish"}
        session = VocabularySession([word], rng=random.Random(1))
        session.current_word = word

        result = session.submit_answer("woman")

        self.assertFalse(result["is_correct"])
        self.assertEqual(word["wrong"], 1)


if __name__ == "__main__":
    unittest.main()
