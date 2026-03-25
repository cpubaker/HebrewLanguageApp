import random
import unittest
from unittest.mock import patch

import test_support

from application.writing_session import WritingSession


class WritingSessionTests(unittest.TestCase):
    def test_next_prompt_prefers_ukrainian_when_available(self):
        word = {
            "hebrew": "שלום",
            "english": "peace",
            "ukrainian": "мир",
            "transcription": "shalom",
        }
        session = WritingSession([word], rng=random.Random(1))

        prompt = session.next_prompt()

        self.assertEqual(prompt["prompt"], "мир")

    def test_submit_answer_returns_empty_status_for_blank_input(self):
        word = {"hebrew": "שלום", "english": "peace", "transcription": "shalom"}
        session = WritingSession([word], rng=random.Random(1))
        session.current_word = word

        result = session.submit_answer("   ")

        self.assertEqual(result["status"], "empty")
        self.assertNotIn("writing_correct", word)
        self.assertNotIn("writing_wrong", word)

    @patch("application.writing_session.datetime")
    def test_submit_answer_updates_correct_counts(self, datetime_mock):
        datetime_mock.now.return_value.isoformat.return_value = "2026-03-25T11:30:00"
        word = {"hebrew": "שָׁלוֹם", "english": "peace", "transcription": "shalom"}
        session = WritingSession([word], rng=random.Random(1))
        session.current_word = word

        result = session.submit_answer("שָׁלוֹם")

        self.assertEqual(result["status"], "submitted")
        self.assertTrue(result["is_correct"])
        self.assertEqual(word["writing_correct"], 1)
        self.assertEqual(word["writing_last_correct"], "2026-03-25T11:30:00")


if __name__ == "__main__":
    unittest.main()
