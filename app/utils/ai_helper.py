from openai import OpenAI
from dotenv import load_dotenv
import os
import tiktoken

# Load .env variables
load_dotenv()

# Read API key
api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    raise RuntimeError("Missing OPENAI_API_KEY. Did you forget to create or configure your .env file?")

# Create OpenAI client
client = OpenAI(api_key=api_key)

# Token counting function
def count_tokens(text: str, model: str = "gpt-4o") -> int:
    enc = tiktoken.encoding_for_model(model)
    tokens = enc.encode(text)
    return len(tokens)

# Main AI call
def get_ai_response(prompt: str):
    """Send a prompt to GPT-4o and return the response lines."""

    # Count and log prompt tokens
    num_tokens_prompt = count_tokens(prompt)
    print(f"[AI PROMPT] Prompt length: {num_tokens_prompt} tokens")

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": "אתה עוזר באיתור חפצים מסוכנים לתינוקות."},
            {"role": "user", "content": prompt}
        ]
    )

    # Log total token usage if available
    if hasattr(response, "usage"):
        print(f"[AI RESPONSE] Total tokens used (prompt + completion): {response.usage.total_tokens}")
        print(f"[AI RESPONSE] Completion tokens: {response.usage.completion_tokens}")

    return response.choices[0].message.content.split("\n")
