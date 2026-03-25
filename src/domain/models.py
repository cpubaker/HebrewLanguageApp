from collections.abc import MutableMapping
from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class MappingRecord(MutableMapping):
    _data: dict = field(default_factory=dict)

    def __getitem__(self, key):
        return self._data[key]

    def __setitem__(self, key, value):
        self._data[key] = value

    def __delitem__(self, key):
        del self._data[key]

    def __iter__(self):
        return iter(self._data)

    def __len__(self):
        return len(self._data)

    def get(self, key, default=None):
        return self._data.get(key, default)

    def to_dict(self):
        return dict(self._data)

    def __eq__(self, other):
        if isinstance(other, MappingRecord):
            return self._data == other._data
        if isinstance(other, dict):
            return self._data == other
        return NotImplemented


@dataclass
class ContextSentence(MappingRecord):
    @classmethod
    def from_dict(cls, data):
        if isinstance(data, cls):
            return data
        return cls(dict(data))

    @property
    def context_id(self):
        return self.get("id")


@dataclass
class Word(MappingRecord):
    TRANSIENT_FIELDS = {"_word_id", "_contexts"}

    @classmethod
    def from_dict(cls, data):
        if isinstance(data, cls):
            return data
        return cls(dict(data))

    @property
    def word_id(self):
        return self.get("_word_id")

    @property
    def contexts(self):
        return self.get("_contexts", [])

    def normalize_loading_fields(self):
        self.setdefault("correct", 0)
        self.setdefault("wrong", 0)
        self.setdefault("writing_correct", 0)
        self.setdefault("writing_wrong", 0)

        if isinstance(self.get("last_correct", False), bool):
            self["last_correct"] = False

        if isinstance(self.get("writing_last_correct", False), bool):
            self["writing_last_correct"] = False

    def set_word_id(self, word_id):
        self["_word_id"] = word_id

    def set_contexts(self, contexts):
        self["_contexts"] = list(contexts)

    def register_correct(self, *, now=None):
        self["correct"] = self.get("correct", 0) + 1
        timestamp = (now or datetime.now()).isoformat(timespec="seconds")
        self["last_correct"] = timestamp
        return timestamp

    def register_wrong(self):
        self["wrong"] = self.get("wrong", 0) + 1

    def register_writing_correct(self, *, now=None):
        self["writing_correct"] = self.get("writing_correct", 0) + 1
        timestamp = (now or datetime.now()).isoformat(timespec="seconds")
        self["writing_last_correct"] = timestamp
        return timestamp

    def register_writing_wrong(self):
        self["writing_wrong"] = self.get("writing_wrong", 0) + 1

    def vocabulary_score(self):
        correct = self.get("correct", 0)
        wrong = self.get("wrong", 0)
        return {
            "correct": correct,
            "wrong": wrong,
            "total": correct + wrong,
        }

    def writing_score(self):
        correct = self.get("writing_correct", 0)
        wrong = self.get("writing_wrong", 0)
        return {
            "correct": correct,
            "wrong": wrong,
            "total": correct + wrong,
            "last_correct": self.get("writing_last_correct", False),
        }

    def to_dict(self, *, strip_transient=False):
        serialized = {}
        for key, value in self._data.items():
            if strip_transient and key in self.TRANSIENT_FIELDS:
                continue

            if key == "_contexts":
                serialized[key] = [
                    context.to_dict() if isinstance(context, ContextSentence) else dict(context)
                    for context in value
                ]
                continue

            serialized[key] = value

        return serialized


@dataclass
class GuideSection(MappingRecord):
    @classmethod
    def from_values(cls, *, title, body, filename=None):
        data = {"title": title, "body": body}
        if filename is not None:
            data["filename"] = filename
        return cls(data)


@dataclass
class ReadingSection(MappingRecord):
    @classmethod
    def from_values(cls, *, title, body, level, filename):
        return cls(
            {
                "title": title,
                "body": body,
                "level": level,
                "filename": filename,
            }
        )


@dataclass
class VerbLesson(MappingRecord):
    @classmethod
    def from_values(cls, *, title, body, filename, image_path=None, audio_path=None):
        return cls(
            {
                "title": title,
                "body": body,
                "filename": filename,
                "image_path": image_path,
                "audio_path": audio_path,
            }
        )
