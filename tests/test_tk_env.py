import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import test_support

from tk_env import configure_tk_environment


class TkEnvTests(unittest.TestCase):
    def test_configure_sets_tk_paths_when_local_runtime_exists(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            project_root = Path(temp_dir)
            src_dir = project_root / "src"
            tk_runtime_dir = project_root / "tk_runtime" / "lib"
            (src_dir).mkdir(parents=True)
            (tk_runtime_dir / "tcl8.6").mkdir(parents=True)
            (tk_runtime_dir / "tk8.6").mkdir(parents=True)
            src_file = src_dir / "main.py"
            src_file.write_text("", encoding="utf-8")

            with patch.dict(os.environ, {}, clear=True):
                configure_tk_environment(str(src_file))

                self.assertEqual(
                    os.environ["TCL_LIBRARY"],
                    str(tk_runtime_dir / "tcl8.6"),
                )
                self.assertEqual(
                    os.environ["TK_LIBRARY"],
                    str(tk_runtime_dir / "tk8.6"),
                )

    def test_configure_leaves_environment_unchanged_without_runtime(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            project_root = Path(temp_dir)
            src_dir = project_root / "src"
            src_dir.mkdir(parents=True)
            src_file = src_dir / "main.py"
            src_file.write_text("", encoding="utf-8")

            with patch.dict(os.environ, {}, clear=True):
                configure_tk_environment(str(src_file))
                self.assertNotIn("TCL_LIBRARY", os.environ)
                self.assertNotIn("TK_LIBRARY", os.environ)


if __name__ == "__main__":
    unittest.main()
