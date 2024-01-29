import torch
from transformers import GenerationConfig, AutoModelForCausalLM, AutoTokenizer
from prompter import Prompter
from peft import PeftModel
import time
import fire
from transformers import BitsAndBytesConfig

from flask import Flask, request, jsonify
from flask_cors import CORS
device = torch.device("cuda:0")
try:
    if torch.backends.mps.is_available():
        device = "mps"
except:  
    pass

app = Flask(__name__)



quantization_config = BitsAndBytesConfig(llm_int8_enable_fp_cpu_offload=True)


prompter = Prompter("")  # You can customize the prompt template here
tokenizer = AutoTokenizer.from_pretrained("beomi/llama-2-ko-7b")

model = AutoModelForCausalLM.from_pretrained(
    "beomi/llama-2-ko-7b",
    load_in_8bit=False,
    torch_dtype=torch.float16,
    device_map="auto",
    quantization_config=quantization_config,
)

model = PeftModel.from_pretrained(
    model,
    "./output_Jan11/checkpoint-400",  # Update with your actual path
    offload_dir=".",
    torch_dtype=torch.float16,
)

model.config.pad_token_id = tokenizer.pad_token_id = 0
model.config.bos_token_id = tokenizer.bos_token_id = 1
model.config.eos_token_id = tokenizer.eos_token_id = 32000
model.eval()
from flask import Flask, request, jsonify
from flask_cors import CORS
CORS(app) 
@app.route('/receive_message', methods=['POST'])  # 'OPTIONS'를 허용된 메서드로 추가합니다.

def receive_message():
   
        print("generating...")
        data = request.get_json()
        instruction = str(data.get('message'))
        print(instruction)
        start_time = time.time()

        response_generator = evaluate(prompter, model, tokenizer, instruction)
        response = next(response_generator, None)

        end_time = time.time()
       
        elapsed_time = end_time - start_time
        print(f"Time taken: {elapsed_time:.4f} seconds")
        response = response.split('<')[0].strip()
        print(response)
        if response:
            return jsonify(response)
       

def evaluate(prompter, model, tokenizer, instruction, temperature=0.1,
             top_p=0.75, top_k=70, num_beams=1, max_new_tokens=512,
             repetition_penalty=4.8, stream_output=True, **kwargs):
    input=None
    prompt = prompter.generate_prompt(instruction, input)
    inputs = tokenizer(prompt, return_tensors="pt", return_token_type_ids=False)
    input_ids = inputs["input_ids"].to(device)
    generation_config = GenerationConfig(
        temperature=temperature,
        top_p=top_p,
        top_k=top_k,
        num_beams=num_beams,
        return_token_type_ids=False,
        repetition_penalty=float(repetition_penalty),
        **kwargs,
    )

    generate_params = {
        "input_ids": input_ids,
        "generation_config": generation_config,
        "return_dict_in_generate": True,
        "output_scores": True,
        "max_new_tokens": max_new_tokens,

    }
    with torch.no_grad():
        generation_output = model.generate(**generate_params)

    s = generation_output.sequences[0]
    output = tokenizer.decode(s)
    yield prompter.get_response(output)

if __name__ == "__main__":
    app.run(host='127.0.0.1', port=5000)
