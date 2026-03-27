from datetime import date
import unittest

import test_support

from application.word_of_day_service import WordOfDayService


class WordOfDayServiceTests(unittest.TestCase):
    def test_get_word_of_day_prefers_words_with_contexts(self):
        service = WordOfDayService(
            [
                {"hebrew": "shalom", "english": "peace", "transcription": "sha-lom"},
                {
                    "hebrew": "kelev",
                    "english": "dog",
                    "transcription": "ke-lev",
                    "_contexts": [{"id": "ctx_dog", "hebrew": "dog context"}],
                },
                {
                    "hebrew": "bayit",
                    "english": "house",
                    "transcription": "ba-yit",
                    "_contexts": [{"id": "ctx_house", "hebrew": "house context"}],
                },
            ]
        )

        result = service.get_word_of_day(date(2026, 3, 27))

        self.assertIn(result["word"]["english"], {"dog", "house"})
        self.assertIsNotNone(result["context"])

    def test_get_word_of_day_is_stable_for_same_date_and_moves_next_day(self):
        service = WordOfDayService(
            [
                {
                    "hebrew": "kelev",
                    "english": "dog",
                    "transcription": "ke-lev",
                    "_contexts": [{"id": "ctx_dog", "hebrew": "dog context"}],
                },
                {
                    "hebrew": "bayit",
                    "english": "house",
                    "transcription": "ba-yit",
                    "_contexts": [{"id": "ctx_house", "hebrew": "house context"}],
                },
            ]
        )

        today = service.get_word_of_day(date(2026, 3, 27))
        repeated = service.get_word_of_day(date(2026, 3, 27))
        next_day = service.get_word_of_day(date(2026, 3, 28))

        self.assertEqual(today["word"]["english"], repeated["word"]["english"])
        self.assertNotEqual(today["word"]["english"], next_day["word"]["english"])

    def test_get_word_of_day_rotates_context_for_selected_word(self):
        service = WordOfDayService(
            [
                {
                    "hebrew": "kelev",
                    "english": "dog",
                    "transcription": "ke-lev",
                    "_contexts": [
                        {"id": "ctx_1", "hebrew": "context one"},
                        {"id": "ctx_2", "hebrew": "context two"},
                    ],
                }
            ]
        )

        today = service.get_word_of_day(date(2026, 3, 27))
        next_day = service.get_word_of_day(date(2026, 3, 28))

        self.assertEqual(today["word"]["english"], "dog")
        self.assertNotEqual(today["context"]["id"], next_day["context"]["id"])


if __name__ == "__main__":
    unittest.main()
