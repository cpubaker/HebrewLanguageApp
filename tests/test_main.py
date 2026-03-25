import unittest
from unittest.mock import Mock, patch

import test_support

import main


class MainSmokeTests(unittest.TestCase):
    @patch("main.HebrewLearningApp")
    @patch("main.build_app_runtime_from_src_file")
    @patch("main.tk.Tk")
    def test_main_builds_runtime_and_enters_mainloop(
        self,
        tk_class_mock,
        build_runtime_mock,
        app_class_mock,
    ):
        root = Mock()
        runtime = object()
        tk_class_mock.return_value = root
        build_runtime_mock.return_value = runtime

        main.main()

        tk_class_mock.assert_called_once_with()
        build_runtime_mock.assert_called_once()
        app_class_mock.assert_called_once_with(root, runtime)
        root.mainloop.assert_called_once_with()


if __name__ == "__main__":
    unittest.main()
