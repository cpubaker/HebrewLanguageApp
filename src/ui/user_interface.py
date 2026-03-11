import tkinter as tk
from tkinter import ttk, messagebox

# Функція для вибору слів
correct_words = {
    "קמתי": 1,   # Прокинувся
    "בוקר": 2,   # Ранок
    "קפה": 3,    # Кава
    "גבינה": 4,  # Сир
    "לוח": 5,    # Дошка
    "מחברת": 6  # Зошит
}
chosen_words = []

def choose_word(word, button):
    if word in correct_words and word not in chosen_words:
        chosen_words.append(word)
        button.config(state="disabled", relief="sunken")
        update_text()
        if len(chosen_words) == len(correct_words):
            messagebox.showinfo("Вітаємо", "Ви правильно заповнили всі пропуски!")

def update_text():
    display_text = f"היום אני [______] מוקדם ב[______]. שתיתי [______] ואכלתי לחם עם [______]. אחר כך, הלכתי לבית הספר ולמדתי עברית. המורה שלי כתבה מילים חדשות על ה[______], ואני כתבתי במחברת. בצהריים, ישבתי עם חברים בגינה ואכלנו תפוח. אחר הצהריים, קראתי ספר בבית. בסוף היום, אני צפיתי בטלוויזיה והלכתי לישון מוקדם."
    for word in chosen_words:
        display_text = display_text.replace(f"[{word}]", word)
    text_label.config(text=display_text, wraplength=500)

# Створення головного вікна
root = tk.Tk()
root.title("Система навчання івриту")
root.geometry("700x500")

# Підказка для користувача
hint_label = tk.Label(root, text="Оберіть правильні слова для заповнення пропусків у тексті", 
                      font=("Arial", 12), fg="blue", wraplength=600, justify="center")
hint_label.pack(pady=10)

# Основний текст на івриті з пропусками
text_label = tk.Label(root, text="", font=("Arial", 14), justify="left", wraplength=500)
text_label.pack(pady=10)

update_text()

# Панель кнопок з варіантами слів
buttons_frame = ttk.Frame(root, padding=10)
buttons_frame.pack()

words = ["קמתי", "בוקר", "קפה", "גבינה", "לוח", "מחברת", "חתול", "אוכל", "גינה", "חול"]
buttons = []

for word in words:
    btn = ttk.Button(buttons_frame, text=word)
    btn.config(command=lambda w=word, b=btn: choose_word(w, b))
    btn.pack(side="left", padx=5, pady=5)
    buttons.append(btn)

# Фрейм для нижніх кнопок
bottom_frame = ttk.Frame(root)
bottom_frame.pack(side="bottom", fill="x", pady=20)

# Кнопка "Словник" (знизу ліворуч)
dictionary_button = ttk.Button(bottom_frame, text="Словник", command=lambda: messagebox.showinfo("Словник", "Тут буде словник"))
dictionary_button.pack(side="left", padx=5)

# Кнопка "Історія" (праворуч від "Словник")
history_button = ttk.Button(bottom_frame, text="Історія", command=lambda: messagebox.showinfo("Історія", "Тут буде історія виконаних вправ"))
history_button.pack(side="left", padx=5)

# Кнопка "Статистика" (праворуч від "Історія")
stats_button = ttk.Button(bottom_frame, text="Статистика", command=lambda: messagebox.showinfo("Статистика", "Тут буде статистика навчання"))
stats_button.pack(side="left", padx=5)

# Кнопка "Вихід" (знизу праворуч)
exit_button = ttk.Button(bottom_frame, text="Вихід", command=root.destroy)
exit_button.pack(side="right", padx=20)

root.mainloop()
