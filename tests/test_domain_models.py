import unittest
from unittest.mock import patch

import test_support

from domain.models import ContextSentence, Word


class DomainModelTests(unittest.TestCase):
    def test_word_register_correct_updates_stats(self):
        word = Word.from_dict({"english": "peace", "hebrew": "שלום"})

        with patch("domain.models.datetime") as datetime_mock:
            datetime_mock.now.return_value.isoformat.return_value = "2026-03-25T12:00:00"
            word.register_correct(now=datetime_mock.now.return_value)

        self.assertEqual(word["correct"], 1)
        self.assertEqual(word["last_correct"], "2026-03-25T12:00:00")

    def test_word_to_dict_can_strip_transient_fields(self):
        word = Word.from_dict(
            {
                "english": "dog",
                "hebrew": "כלב",
                "_word_id": "word_dog",
                "_contexts": [ContextSentence.from_dict({"id": "ctx_1"})],
            }
        )

        serialized = word.to_dict(strip_transient=True)

        self.assertNotIn("_word_id", serialized)
        self.assertNotIn("_contexts", serialized)

    def test_context_sentence_from_dict_preserves_values(self):
        context = ContextSentence.from_dict(
            {"id": "ctx_1", "hebrew": "שלום", "translation": "Peace"}
        )

        self.assertEqual(context.context_id, "ctx_1")
        self.assertEqual(context["translation"], "Peace")


if __name__ == "__main__":
    unittest.main()
