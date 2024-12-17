# **Project Overview**

This app was designed by **Yevhen Nedashkivskyi** as a **research project for individual Hebrew learning**.

---

## **Work Modes**

Depending on configuration, the app supports three modes:

1. **Lightweight**  
   Works with a pre-defined JSON file (`hebrew_words.json`).

2. **Normal**  
   Integrates a database and the OpenAI API.

3. **Research**  
   Combines a database, the OpenAI API, and local language models for enhanced performance.

---

## **Language Models Used**

The following pre-trained language models are utilized in the project:

### 1. **AlephBERT**
   - **Source**: [AlephBERT on Hugging Face](https://huggingface.co/onlplab/alephbert-base)
   - **Authors**: *Onlp Lab*
   - **Citation**:
     ```bibtex
     @inproceedings{alephbert2021,
       title={AlephBERT: A Hebrew Language Model},
       author={Onlp Lab},
       year={2021}
     }
     ```

### 2. **DictaBERT**
   - **Source**: [DictaBERT GitHub](https://github.com/Dicta-Labs/DictaBERT)
   - **Authors**: *Dicta Labs*
   - **Citation**:
     ```bibtex
     @misc{dictabert,
       title={DictaBERT: Hebrew Pretrained Model},
       author={Dicta Labs},
       year={2021},
       howpublished={\url{https://github.com/Dicta-Labs/DictaBERT}}
     }
     ```

### 3. **DictaLM2**
   - **Source**: [Dicta Language Models](https://dicta-labs.org/)
   - **Authors**: *Dicta Labs*
   - **Citation**:
     ```bibtex
     @misc{dictalm2,
       title={DictaLM2: Hebrew Language Models},
       author={Dicta Labs},
       year={2022},
       howpublished={\url{https://dicta-labs.org/}}
     }
     ```

### 4. **HeBERT**
   - **Source**: [HeBERT on Hugging Face](https://huggingface.co/avichr/heBERT)
   - **Authors**: *Avichai Levy*
   - **Citation**:
     ```bibtex
     @misc{hebert2021,
       title={HeBERT: Pretrained BERT for Hebrew},
       author={Avichai Levy},
       year={2021},
       howpublished={\url{https://huggingface.co/avichr/heBERT}}
     }
     ```

### 5. **OpenAI GPT Models**
   - **Source**: [OpenAI Models](https://openai.com/)
   - **Authors**: *OpenAI*
   - **Citation**:
     ```bibtex
     @article{openai2023,
       title={GPT Models by OpenAI},
       author={OpenAI},
       year={2023},
       journal={openai.com}
     }
     ```

### 6. **T5 (Text-to-Text Transfer Transformer)**
   - **Source**: [T5 on Hugging Face](https://huggingface.co/models?search=T5)
   - **Authors**: *Google Research*
   - **Citation**:
     ```bibtex
     @article{raffel2020exploring,
       title={Exploring the Limits of Transfer Learning with a Unified Text-to-Text Transformer},
       author={Colin Raffel and Noam Shazeer and Adam Roberts and others},
       year={2020},
       journal={Journal of Machine Learning Research},
       volume={21},
       number={140},
       pages={1-67}
     }
     ```

---

## **Prerequisites**

To run this app, ensure the following requirements are met:

1. **Libraries**  
   Install all required libraries using `pip`:
   ```bash
   pip install json openai os random torch tkinter transformers


## **OpenAI API Key Setup**

To enable OpenAI API functionality in this project, follow these steps:

1. **Obtain an API Key**  
   - Visit [OpenAI's platform](https://platform.openai.com/) to obtain your API key.

2. **Add the API Key to Environment Variables**

   - **On Windows:**
     Open Command Prompt and run:
     ```bash
     setx OPENAI_API_KEY "your_api_key_here"
     ```

   - **On macOS/Linux:**
     Open a terminal and run:
     ```bash
     export OPENAI_API_KEY="your_api_key_here"
     ```

3. **Verify the Key in Your Code**  
   In your Python script, load the API key as follows:
   ```python
   import os
   import openai

   openai.api_key = os.getenv("OPENAI_API_KEY")

   if not openai.api_key:
       raise ValueError("OpenAI API key not found. Set it as an environment variable.")
