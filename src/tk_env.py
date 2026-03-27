import os
from pathlib import Path


def configure_tk_environment(src_file: str) -> None:
    project_root = Path(src_file).resolve().parent.parent
    tk_runtime_root = project_root / "tk_runtime" / "lib"
    tcl_library = tk_runtime_root / "tcl8.6"
    tk_library = tk_runtime_root / "tk8.6"

    if not tcl_library.is_dir() or not tk_library.is_dir():
        return

    os.environ.setdefault("TCL_LIBRARY", str(tcl_library))
    os.environ.setdefault("TK_LIBRARY", str(tk_library))
