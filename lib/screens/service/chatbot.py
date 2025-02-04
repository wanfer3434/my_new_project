from transformers import AutoModelForCausalLM, AutoTokenizer

# Cargar el modelo y el tokenizador preentrenado
model_name = "microsoft/DialoGPT-medium"
model = AutoModelForCausalLM.from_pretrained(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)

def chatbot_response(user_input):
    # Codificar la entrada del usuario
    new_user_input_ids = tokenizer.encode(user_input + tokenizer.eos_token, return_tensors='pt')

    # Generar la respuesta del modelo
    bot_output = model.generate(new_user_input_ids, max_length=1000, pad_token_id=tokenizer.eos_token_id)

    # Decodificar la respuesta generada
    bot_response = tokenizer.decode(bot_output[:, new_user_input_ids.shape[-1]:][0], skip_special_tokens=True)

    return bot_response
