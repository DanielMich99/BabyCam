from openai import OpenAI
from dotenv import load_dotenv
import os
import tiktoken

# Load environment variables from .env file
load_dotenv()

# Read OpenAI API key
api_key = os.getenv("OPENAI_API_KEY")

# Validate that the API key exists
if not api_key:
    raise RuntimeError("Missing OPENAI_API_KEY. Did you forget to create or configure your .env file?")

# Create OpenAI client instance
client = OpenAI(api_key=api_key)

# Utility function to count the number of tokens in a given prompt
def count_tokens(text: str, model: str = "gpt-4o") -> int:
    enc = tiktoken.encoding_for_model(model)
    tokens = enc.encode(text)
    return len(tokens)

# Main function to query GPT-4o with a prompt and return a list of response lines
def get_ai_response(prompt: str):
    """
    Sends a prompt to OpenAI's GPT-4o and returns the response as a list of strings (lines).
    """

    # Log the number of tokens in the prompt
    num_tokens_prompt = count_tokens(prompt)
    print(f"[AI PROMPT] Prompt length: {num_tokens_prompt} tokens")

    # Call OpenAI's chat completion API
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": "אתה עוזר באיתור חפצים מסוכנים לתינוקות."},  # system message in Hebrew
            {"role": "user", "content": prompt}
        ]
    )

    # If usage info is available, log it
    if hasattr(response, "usage"):
        print(f"[AI RESPONSE] Total tokens used (prompt + completion): {response.usage.total_tokens}")
        print(f"[AI RESPONSE] Completion tokens: {response.usage.completion_tokens}")

    # Return the response as a list of lines
    return response.choices[0].message.content.split("\n")
