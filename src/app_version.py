from functools import lru_cache
from pathlib import Path
import subprocess


APP_NAME = "Learn Hebrew"
VERSION_MAJOR = 0
VERSION_MINOR = 1
FALLBACK_PATCH = 29


def _get_repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


@lru_cache(maxsize=1)
def get_app_version() -> str:
    patch = FALLBACK_PATCH

    try:
        result = subprocess.run(
            ["git", "rev-list", "--count", "HEAD"],
            cwd=_get_repo_root(),
            check=True,
            capture_output=True,
            text=True,
        )
        patch = int(result.stdout.strip())
    except (OSError, ValueError, subprocess.SubprocessError):
        pass

    return f"{VERSION_MAJOR}.{VERSION_MINOR}.{patch}"


def get_version_label() -> str:
    return f"v{get_app_version()}"
