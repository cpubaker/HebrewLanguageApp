import tkinter as tk
import json
import random
import os

class HebrewLearningApp:
    def __init__(self, master):
        self.master = master
        self.master.title("Learn Hebrew")
        
        self.words = self.load_words()
        self.current_word = None
        self.correct_btn = None
        
        self.label = tk.Label(master, text="", font=('Helvetica', 18))
        self.label.pack(pady=20)
        
        self.button_frame = tk.Frame(master)
        self.button_frame.pack(pady=20)
        
        self.feedback_label = tk.Label(master, text="", font=('Helvetica', 14))
        self.feedback_label.pack(pady=10)
        
        self.score_label = tk.Label(master, text="", font=('Helvetica', 14))
        self.score_label.pack(pady=5)
        
        self.next_button = tk.Button(master, text="Next", command=self.next_word)
        self.next_button.pack(pady=20)
        
        self.next_word()

    def load_words(self):
        base_dir = os.path.dirname(__file__) 
        file_path = os.path.join(base_dir, 'hebrew_words.json')
        with open('hebrew_words.json', 'r', encoding='utf-8') as file:
            return json.load(file)
    
    def next_word(self):
        self.current_word = random.choice(self.words)
        self.display_word()
        
    def display_word(self):
        correct_translation = self.current_word['english']
        wrong_translation = random.choice([w['english'] for w in self.words if w != self.current_word])
        options = [correct_translation, wrong_translation]
        random.shuffle(options)
        
        self.label.config(text=self.current_word['hebrew'])
        self.feedback_label.config(text="")
        self.score_label.config(text=f"Correct: {self.current_word['correct']}, Wrong: {self.current_word['wrong']}")
        
        for widget in self.button_frame.winfo_children():
            widget.destroy()
        
        for option in options:
            btn = tk.Button(self.button_frame, text=option, command=lambda opt=option: self.check_answer(opt))
            btn.pack(side=tk.LEFT, padx=10)
            if option == correct_translation:
                self.correct_btn = btn
    
    def check_answer(self, translation):
        if translation == self.current_word['english']:
            self.current_word['correct'] += 1
            self.current_word['last_correct'] = True
            self.feedback_label.config(text="Correct!", fg="green")
        else:
            self.current_word['wrong'] += 1
            self.current_word['last_correct'] = False
            self.feedback_label.config(text="Wrong!", fg="red")
        self.score_label.config(text=f"Correct: {self.current_word['correct']}, Wrong: {self.current_word['wrong']}")
        self.save_progress()
        
    def save_progress(self):
        base_dir = os.path.dirname(__file__)  # Directory of the script
        file_path = os.path.join(base_dir, 'hebrew_words.json')  # Path to the JSON file
        with open(file_path, 'w') as file:
            json.dump(self.words, file, ensure_ascii=False, indent=4)

def main():
    root = tk.Tk()
    app = HebrewLearningApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
