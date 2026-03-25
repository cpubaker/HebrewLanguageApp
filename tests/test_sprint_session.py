import random
import unittest
from unittest.mock import patch

import test_support

from application.sprint_session import SprintSession
from domain.models import Word


class SprintSessionTests(unittest.TestCase):
    def test_can_start_requires_two_distinct_translations(self):
        session = SprintSession(
            [
                {"hebrew": "ish", "english": "man", "transcription": "ish"},
                {"hebrew": "gever", "english": "man", "transcription": "gever"},
            ]
        )

        self.assertFalse(session.can_start())

    def test_next_prompt_returns_word_and_two_options(self):
        words = [
            {"hebrew": "ish", "english": "man", "transcription": "ish"},
            {"hebrew": "isha", "english": "woman", "transcription": "isha"},
            {"hebrew": "sefer", "english": "book", "transcription": "sefer"},
        ]
        session = SprintSession(words, rng=random.Random(7))

        prompt = session.next_prompt()

        self.assertIsNotNone(prompt)
        self.assertIsInstance(session.words[0], Word)
        self.assertIn(prompt["word"], words)
        self.assertEqual(len(prompt["options"]), 2)
        self.assertEqual(len(set(prompt["options"])), 2)
        self.assertIn(prompt["word"]["english"], prompt["options"])

    @patch("application.sprint_session.datetime")
    def test_submit_answer_updates_correct_counts(self, datetime_mock):
        datetime_mock.now.return_value.isoformat.return_value = "2026-03-25T10:15:00"
        session = SprintSession(
            [
                {"hebrew": "ish", "english": "man", "transcription": "ish"},
                {"hebrew": "isha", "english": "woman", "transcription": "isha"},
            ],
            rng=random.Random(1),
        )
        session.current_word = session.words[0]

        result = session.submit_answer("man")

        self.assertTrue(result["is_correct"])
        self.assertEqual(session.correct_count, 1)
        self.assertEqual(session.wrong_count, 0)
        self.assertEqual(session.words[0]["correct"], 1)
        self.assertEqual(session.words[0]["last_correct"], "2026-03-25T10:15:00")

    def test_submit_answer_updates_wrong_counts(self):
        session = SprintSession(
            [
                {"hebrew": "ish", "english": "man", "transcription": "ish"},
                {"hebrew": "isha", "english": "woman", "transcription": "isha"},
            ]
        )
        session.current_word = session.words[0]

        result = session.submit_answer("woman")

        self.assertFalse(result["is_correct"])
        self.assertEqual(result["correct_translation"], "man")
        self.assertEqual(session.correct_count, 0)
        self.assertEqual(session.wrong_count, 1)
        self.assertEqual(session.words[0]["wrong"], 1)


if __name__ == "__main__":
    unittest.main()
