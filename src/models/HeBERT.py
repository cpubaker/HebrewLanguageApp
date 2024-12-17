from transformers import AutoTokenizer, AutoModelForMaskedLM, pipeline
import json

def main():
    model_name = "avichr/heBERT"

    # Load the model and tokenizer
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForMaskedLM.from_pretrained(model_name, trust_remote_code=True)

    # Create a pipeline for masked language modeling
    fill_mask = pipeline("fill-mask", model=model, tokenizer=tokenizer)

    # Load sentences from the JSON file
    input_file = "Test_sentences.json"
    output_file = "HeBert_result.txt"

    with open(input_file, "r", encoding="utf-8") as f:
        sentences = json.load(f)

    # Open file to write results
    with open(output_file, "w", encoding="utf-8") as out_file:
        for item in sentences:
            sentence = item['sentence'] if isinstance(item, dict) else item
            print(f"Processing sentence: {sentence}")
            try:
                results = fill_mask(sentence)

                # Write results to the file
                out_file.write(f"Sentence: {sentence}\n")
                for prediction in results:
                    token_str = prediction['token_str']
                    score = prediction['score']
                    print(f"Token: {token_str} | Score: {score:.4f}")
                    out_file.write(f"Token: {token_str} | Score: {score:.4f}\n")
                out_file.write("\n")
            except Exception as e:
                print(f"Error processing sentence: {sentence} | Error: {e}")

if __name__ == "__main__":
    main()
