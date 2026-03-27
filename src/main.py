import tkinter as tk
from tkinter import messagebox

from app_runtime import build_app_runtime_from_src_file
from domain.errors import AppDataError
from tk_env import configure_tk_environment
from ui.main_window import HebrewLearningApp


def main():
    configure_tk_environment(__file__)
    root = tk.Tk()
    try:
        runtime = build_app_runtime_from_src_file(__file__)
        HebrewLearningApp(root, runtime)
    except AppDataError as error:
        messagebox.showerror(error.dialog_title, error.dialog_message)
        root.destroy()
        return

    root.mainloop()


if __name__ == "__main__":
    main()
