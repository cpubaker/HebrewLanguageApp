import random
import unittest
from unittest.mock import patch

import test_support

from application.writing_session import WritingSession
from domain.models import Word


class WritingSessionTests(unittest.TestCase):
    def test_next_prompt_prefers_ukrainian_when_available(self):
        word = {
            "hebrew": "\u05e9\u05dc\u05d5\u05dd",
            "english": "peace",
            "ukrainian": "mir",
            "transcription": "shalom",
        }
        session = WritingSession([word], rng=random.Random(1))

        prompt = session.next_prompt()

        self.assertIsInstance(session.words[0], Word)
        self.assertEqual(prompt["prompt"], "mir")

    def test_submit_answer_returns_empty_status_for_blank_input(self):
        session = WritingSession(
            [{"hebrew": "\u05e9\u05dc\u05d5\u05dd", "english": "peace", "transcription": "shalom"}],
            rng=random.Random(1),
        )
        session.current_word = session.words[0]

        result = session.submit_answer("   ")

        self.assertEqual(result["status"], "empty")
        self.assertEqual(session.words[0]["writing_correct"], 0)
        self.assertEqual(session.words[0]["writing_wrong"], 0)

    @patch("application.writing_session.datetime")
    def test_submit_answer_updates_correct_counts(self, datetime_mock):
        datetime_mock.now.return_value.isoformat.return_value = "2026-03-25T11:30:00"
        session = WritingSession(
            [{"hebrew": "\u05e9\u05c1\u05dc\u05d5\u05b9\u05dd", "english": "peace", "transcription": "shalom"}],
            rng=random.Random(1),
        )
        session.current_word = session.words[0]

        result = session.submit_answer("\u05e9\u05c1\u05dc\u05d5\u05b9\u05dd")

        self.assertEqual(result["status"], "submitted")
        self.assertTrue(result["is_correct"])
        self.assertEqual(session.words[0]["writing_correct"], 1)
        self.assertEqual(session.words[0]["writing_last_correct"], "2026-03-25T11:30:00")


if __name__ == "__main__":
    unittest.main()
