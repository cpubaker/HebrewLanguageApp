from dataclasses import dataclass
import os


@dataclass(frozen=True)
class AppPaths:
    project_root: str
    words_file: str
    word_progress_file: str
    guide_dir: str
    verbs_dir: str
    reading_dir: str
    contexts_dir: str
    context_sentences_file: str
    word_context_links_file: str
    audio_dir: str
    verbs_audio_dir: str
    images_dir: str
    verbs_images_dir: str
    words_images_dir: str
    reading_images_dir: str
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
            word_progress_file=os.path.join(
                project_root, "data", "runtime", "word_progress.json"
            ),
            guide_dir=os.path.join(project_root, "data", "input", "guide"),
            verbs_dir=os.path.join(project_root, "data", "input", "verbs"),
            reading_dir=os.path.join(project_root, "data", "input", "reading"),
            contexts_dir=os.path.join(project_root, "data", "input", "contexts"),
            context_sentences_file=os.path.join(
                project_root, "data", "input", "contexts", "sentences.json"
            ),
            word_context_links_file=os.path.join(
                project_root, "data", "input", "contexts", "word_context_links.json"
            ),
            audio_dir=os.path.join(project_root, "data", "input", "audio"),
            verbs_audio_dir=os.path.join(
                project_root, "data", "input", "audio", "verbs"
            ),
            images_dir=os.path.join(project_root, "data", "input", "images"),
            verbs_images_dir=os.path.join(
                project_root, "data", "input", "images", "verbs"
            ),
            words_images_dir=os.path.join(
                project_root, "data", "input", "images", "words"
            ),
            reading_images_dir=os.path.join(
                project_root, "data", "input", "images", "reading"
            ),
            icon_file=os.path.join(project_root, "src", "ui", "app_icon.png"),
        )
