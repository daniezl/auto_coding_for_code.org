from openai import OpenAI
from apiKey import DEEPSEEK_API_KEY
import json
import os

# File to store conversation history
HISTORY_FILE = "conversation_history.json"

def load_history():
    if os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE, "r", encoding='utf-8') as f:
            return json.load(f)
    return []

def save_history(history):
    with open(HISTORY_FILE, "w", encoding='utf-8') as f:
        json.dump(history, f, indent=2)

def call_deepseek(prompt):
    client = OpenAI(
        api_key=DEEPSEEK_API_KEY,
        base_url="https://api.deepseek.com/v1"
    )
    
    # Load existing conversation history
    history = load_history()
    
    # Add new prompt to messages
    messages = history + [{"role": "user", "content": prompt}]
    
    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=messages,
        temperature=0.7,
        max_tokens=1000
    )
    
    # Get the response content
    assistant_message = response.choices[0].message.content
    
    # Update history with both the new prompt and response
    history.append({"role": "user", "content": prompt})
    history.append({"role": "assistant", "content": assistant_message})
    
    # Save updated history
    save_history(history)
    
    return assistant_message

if __name__ == "__main__":
    try:
        # Read prompt from file
        with open("prompt.txt", "r", encoding='utf-8') as f:
            prompt = f.read()
            
        # Call DeepSeek and get response
        response = call_deepseek(prompt)
        
        # Save response to file
        with open("response.txt", "w", encoding='utf-8') as f:
            f.write(response)
            
    except FileNotFoundError:
        with open("response.txt", "w", encoding='utf-8') as f:
            f.write("Error: prompt.txt not found!")
    except Exception as e:
        with open("response.txt", "w", encoding='utf-8') as f:
            f.write(f"An error occurred: {str(e)}")