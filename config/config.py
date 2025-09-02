import os

from dotenv import load_dotenv

load_dotenv()

# API Keys
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# Model Configuration
MODEL_NAME = "llama-3.1-8b-instant"
EMBEDDING_MODEL_NAME = "text-embedding-3-small"  # Default OpenAI embedding model