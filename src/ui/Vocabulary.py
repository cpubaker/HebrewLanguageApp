import tkinter as tk
from tkinter import ttk, messagebox

# Функції
def save_word():
    word = word_entry.get()
    transcription = transcription_entry.get()
    translation = translation_entry.get()
    part_of_speech = part_of_speech_var.get()
    binyan = binyan_var.get()
    example = example_entry.get("1.0", "end").strip()

    if not (word and transcription and translation and part_of_speech and example):
        messagebox.showerror("Помилка", "Будь ласка, заповніть всі обов'язкові поля.")
        return

    # Виведення даних у консоль для тестування
    print(f"Слово: {word}")
    print(f"Транскрипція: {transcription}")
    print(f"Переклад: {translation}")
    print(f"Частина мови: {part_of_speech}")
    print(f"Біньян: {binyan}")
    print(f"Приклад: {example}")

    messagebox.showinfo("Збережено", "Дані успішно збережені!")

def edit_word():
    messagebox.showinfo("Редагування", "Режим редагування активовано.")

# Головне вікно
root = tk.Tk()
root.title("Редактор Словника")
root.geometry("600x400")

# Поля вводу
tk.Label(root, text="Слово (на івриті)").grid(row=0, column=0, sticky="w", padx=10, pady=5)
word_entry = tk.Entry(root, width=40)
word_entry.grid(row=0, column=1, padx=10, pady=5)
word_entry.insert(0, "לשחות")  # Слово "плавати"

tk.Label(root, text="Слово з огласовками (транскрипція)").grid(row=1, column=0, sticky="w", padx=10, pady=5)
transcription_entry = tk.Entry(root, width=40)
transcription_entry.grid(row=1, column=1, padx=10, pady=5)
transcription_entry.insert(0, "לִשְׂחוֹת (лісхот)")

tk.Label(root, text="Переклад українською").grid(row=2, column=0, sticky="w", padx=10, pady=5)
translation_entry = tk.Entry(root, width=40)
translation_entry.grid(row=2, column=1, padx=10, pady=5)
translation_entry.insert(0, "плавати")

tk.Label(root, text="Частина мови").grid(row=3, column=0, sticky="w", padx=10, pady=5)
part_of_speech_var = tk.StringVar()
part_of_speech_combobox = ttk.Combobox(root, textvariable=part_of_speech_var, width=37)
part_of_speech_combobox["values"] = ("Іменник", "Дієслово", "Прикметник", "Прислівник")
part_of_speech_combobox.grid(row=3, column=1, padx=10, pady=5)
part_of_speech_combobox.set("Дієслово")

tk.Label(root, text="Біньян").grid(row=4, column=0, sticky="w", padx=10, pady=5)
binyan_var = tk.StringVar()
binyan_combobox = ttk.Combobox(root, textvariable=binyan_var, width=37)
binyan_combobox["values"] = ("Па'аль", "Пі'ель", "Гіф'іль", "Гіту'ль")
binyan_combobox.grid(row=4, column=1, padx=10, pady=5)
binyan_combobox.set("Па'аль")

tk.Label(root, text="Приклад контексту").grid(row=5, column=0, sticky="nw", padx=10, pady=5)
example_entry = tk.Text(root, width=40, height=4)
example_entry.grid(row=5, column=1, padx=10, pady=5)
example_entry.insert("1.0", "בכל קיץ אני אוהב לשחות בים עם החברים שלי.\n(Кожного літа я люблю плавати в морі зі своїми друзями.)")

# Кнопки
buttons_frame = ttk.Frame(root)
buttons_frame.grid(row=6, column=0, columnspan=2, pady=20)

save_button = ttk.Button(buttons_frame, text="Зберегти", command=save_word)
save_button.pack(side="left", padx=10)

edit_button = ttk.Button(buttons_frame, text="Редагувати", command=edit_word)
edit_button.pack(side="left", padx=10)

root.mainloop()
