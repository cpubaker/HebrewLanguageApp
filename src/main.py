import tkinter as tk

from ui.main_window import HebrewLearningApp


def main():
    root = tk.Tk()
    HebrewLearningApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
