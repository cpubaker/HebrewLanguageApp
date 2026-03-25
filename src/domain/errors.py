class AppDataError(Exception):
    """Base class for app data loading errors."""


class MissingDataPathError(AppDataError, FileNotFoundError):
    def __init__(self, path, *, resource_label):
        self.path = path
        self.resource_label = resource_label
        super().__init__(path)

    @property
    def dialog_title(self):
        if self.resource_label.endswith("file"):
            return "File not found"
        return "Folder not found"

    @property
    def dialog_message(self):
        return f"Could not find {self.resource_label}:\n{self.path}"
