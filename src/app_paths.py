from dataclasses import dataclass
import os


@dataclass(frozen=True)
class AppPaths:
    project_root: str
    words_file: str
    guide_dir: str
    verbs_dir: str
    reading_dir: str
    icon_file: str

    @classmethod
    def from_src_file(cls, src_file: str) -> "AppPaths":
        src_dir = os.path.dirname(os.path.abspath(src_file))
        project_root = os.path.dirname(src_dir)

        if os.path.basename(src_dir) == "ui":
            project_root = os.path.dirname(project_root)

        return cls(
            project_root=project_root,
            words_file=os.path.join(project_root, "data", "input", "hebrew_words.json"),
            guide_dir=os.path.join(project_root, "data", "input", "guide"),
            verbs_dir=os.path.join(project_root, "data", "input", "verbs"),
            reading_dir=os.path.join(project_root, "data", "input", "reading"),
            icon_file=os.path.join(project_root, "src", "ui", "app_icon.png"),
        )
