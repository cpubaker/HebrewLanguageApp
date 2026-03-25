import unittest

import test_support

from application.progress_service import ProgressService


class FakeProgressRepository:
    def __init__(self):
        self.saved_words = None

    def save_words(self, words):
        self.saved_words = words


class ProgressServiceTests(unittest.TestCase):
    def test_save_words_delegates_to_repository(self):
        repository = FakeProgressRepository()
        service = ProgressService(repository)
        words = ["word-1", "word-2"]

        service.save_words(words)

        self.assertEqual(repository.saved_words, words)


if __name__ == "__main__":
    unittest.main()
