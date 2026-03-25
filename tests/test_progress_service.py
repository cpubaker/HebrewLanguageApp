import unittest

import test_support

from application.progress_service import ProgressService


class FakeProgressRepository:
    def __init__(self):
        self.saved_words = None
        self.save_calls = []

    def save_words(self, words):
        self.saved_words = words
        self.save_calls.append(words)


class ProgressServiceTests(unittest.TestCase):
    def test_save_words_delegates_to_repository(self):
        repository = FakeProgressRepository()
        service = ProgressService(repository)
        words = ["word-1", "word-2"]

        service.save_words(words)

        self.assertEqual(repository.saved_words, words)

    def test_queue_save_defers_write_until_flush(self):
        repository = FakeProgressRepository()
        service = ProgressService(repository)
        words = ["word-1", "word-2"]

        service.queue_save(words)

        self.assertEqual(repository.save_calls, [])
        self.assertTrue(service.flush())
        self.assertEqual(repository.saved_words, words)

    def test_queue_save_flushes_only_latest_pending_words(self):
        repository = FakeProgressRepository()
        service = ProgressService(repository)

        service.queue_save(["old"])
        service.queue_save(["new"])

        service.flush()

        self.assertEqual(repository.save_calls, [["new"]])
        self.assertFalse(service.flush())


if __name__ == "__main__":
    unittest.main()
