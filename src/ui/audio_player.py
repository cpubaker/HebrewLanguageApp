import os
import subprocess
import sys


class AudioPlaybackError(RuntimeError):
    pass


class AudioPlayer:
    _alias = "hebrew_language_app_audio"

    @classmethod
    def play(cls, audio_path):
        if not audio_path or not os.path.exists(audio_path):
            raise FileNotFoundError(audio_path or "")

        if os.name == "nt":
            try:
                cls._play_with_windows_mci(audio_path)
                return
            except AudioPlaybackError:
                try:
                    os.startfile(audio_path)
                    return
                except OSError as error:
                    raise AudioPlaybackError(str(error)) from error

        opener = "open" if os.name == "posix" and sys.platform == "darwin" else "xdg-open"
        try:
            subprocess.Popen([opener, audio_path])
        except OSError as error:
            raise AudioPlaybackError(str(error)) from error

    @classmethod
    def stop(cls):
        if os.name != "nt":
            return

        try:
            cls._send_windows_mci_command(f"stop {cls._alias}")
        except AudioPlaybackError:
            pass

        try:
            cls._send_windows_mci_command(f"close {cls._alias}")
        except AudioPlaybackError:
            pass

    @classmethod
    def _play_with_windows_mci(cls, audio_path):
        import ctypes

        cls.stop()

        safe_path = audio_path.replace('"', '""')
        cls._send_windows_mci_command(
            f'open "{safe_path}" type mpegvideo alias {cls._alias}'
        )
        cls._send_windows_mci_command(f"play {cls._alias}")

    @staticmethod
    def _send_windows_mci_command(command):
        import ctypes

        result = ctypes.windll.winmm.mciSendStringW(command, None, 0, 0)
        if result != 0:
            raise AudioPlaybackError(f"MCI command failed: {command}")
