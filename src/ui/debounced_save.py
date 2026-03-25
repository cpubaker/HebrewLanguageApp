class DebouncedSaveController:
    def __init__(self, widget, progress_service, delay_ms=800):
        self.widget = widget
        self.progress_service = progress_service
        self.delay_ms = delay_ms
        self._job = None

    def request_save(self, words):
        self.progress_service.queue_save(words)
        if not self.widget.winfo_exists():
            return

        if self._job is not None:
            self.widget.after_cancel(self._job)

        self._job = self.widget.after(self.delay_ms, self.flush)

    def flush(self):
        self._job = None
        self.progress_service.flush()

    def cancel(self):
        if self._job is not None and self.widget.winfo_exists():
            self.widget.after_cancel(self._job)
        self._job = None
