# Anime Recommender System with LLMOps

An intelligent anime recommendation system that uses OpenAI embeddings and Groq's LLM to provide personalized anime suggestions based on user preferences.

## 🎯 Features

- **Semantic Search**: Uses OpenAI embeddings to understand anime descriptions and user queries
- **AI-Powered Recommendations**: Leverages Groq's Llama 3.1 model for intelligent recommendations
- **Vector Database**: ChromaDB for efficient similarity search
- **Web Interface**: Clean Streamlit UI for easy interaction
- **Logging & Error Handling**: Comprehensive logging and custom exception handling

## 📋 Prerequisites

- Python 3.10 or 3.11
- OpenAI API key (for embeddings)
- Groq API key (for LLM recommendations)
- UV package manager (recommended) or pip

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ANIME-RECOMMENDER-SYSTEM-LLMOPS
```

### 2. Install UV (Recommended Package Manager)

```bash
# On macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# On macOS with Homebrew
brew install uv
```

### 3. Set Up Environment

Create a `.env` file in the project root with your API keys:

```bash
OPENAI_API_KEY=sk-your-openai-api-key-here
GROQ_API_KEY=gsk_your-groq-api-key-here
```

### 4. Install Dependencies

Using UV (recommended):
```bash
# Create virtual environment
uv venv --python 3.10

# Activate virtual environment
source .venv/bin/activate  # On macOS/Linux
# or
.venv\Scripts\activate  # On Windows

# Install dependencies
uv pip install -e .
```

Using pip:
```bash
# Create virtual environment
python -m venv .venv

# Activate virtual environment
source .venv/bin/activate  # On macOS/Linux
# or
.venv\Scripts\activate  # On Windows

# Install dependencies
pip install -e .
```

### 5. Build the Vector Store

Before running the app, you need to build the vector store with anime embeddings:

```bash
# Using default settings
uv run python pipeline/build_pipeline.py

# Or with custom options
uv run python pipeline/build_pipeline.py --embed-model-name text-embedding-3-large --persist-dir custom_db
```

### 6. Run the Application

```bash
uv run streamlit run app/app.py
```

The app will be available at `http://localhost:8501`

## 📁 Project Structure

```
ANIME-RECOMMENDER-SYSTEM-LLMOPS/
├── app/
│   ├── __init__.py
│   └── app.py              # Streamlit web interface
├── config/
│   ├── __init__.py
│   ├── config.py           # Configuration settings
│   └── parse_arguments.py  # CLI argument parser
├── data/
│   ├── anime_updated.csv   # Processed anime dataset
│   └── anime_with_synopsis.csv  # Original anime data
├── pipeline/
│   ├── __init__.py
│   ├── build_pipeline.py   # Build vector store
│   └── pipeline.py         # Recommendation pipeline
├── src/
│   ├── __init__.py
│   ├── data_loader.py      # Data loading utilities
│   ├── prompt_template.py  # LLM prompt templates
│   ├── recommender.py      # Core recommendation logic
│   └── vector_store.py     # Vector store management
├── utils/
│   ├── __init__.py
│   ├── custom_exception.py # Custom exception handling
│   └── logger.py           # Logging configuration
├── .env                    # API keys (create this)
├── pyproject.toml          # Project dependencies
└── README.md               # This file
```

## ⚙️ Configuration Options

### Embedding Models

You can choose from different OpenAI embedding models:

- `text-embedding-3-small` (default) - Most cost-effective
- `text-embedding-3-large` - Higher quality embeddings
- `text-embedding-ada-002` - Legacy model

### Command Line Options

When building the vector store:

```bash
uv run pipeline/build_pipeline.py [OPTIONS]

Options:
  --embed-model-name TEXT  OpenAI embedding model name
  --persist-dir TEXT       Directory to persist vector store
  --csv-path TEXT          Path to CSV file with anime data
```

## 🔧 Development

### Running with Different Embedding Models

```bash
# Build vector store with large embeddings
uv run pipeline/build_pipeline.py --embed-model-name text-embedding-3-large

# Run the app (it will use the same embedding model automatically)
uv run streamlit run app/app.py
```

### Rebuilding the Vector Store

If you update the anime dataset or want to change the embedding model:

```bash
# Delete existing vector store
rm -rf chroma_db/

# Rebuild with new settings
uv run pipeline/build_pipeline.py
```

## 🐛 Troubleshooting

### Common Issues

1. **"OPENAI_API_KEY not found"**: Make sure your `.env` file contains valid API keys

2. **"command not found: streamlit"**: Always use `uv run` prefix when using UV:
   ```bash
   uv run streamlit run app/app.py
   ```

3. **Deprecation warnings**: The warning about `Chain.__call__` is expected and doesn't affect functionality

### Logs

Check the `logs/` directory for detailed application logs if you encounter issues.

## 📝 License

This project is part of an LLMOps demonstration and is available for educational purposes.

## 🚢 Deployment

For production deployment using Docker and Kubernetes, see the [Deployment Guide](DEPLOYMENT_GUIDE.md).

**Security Note**: The `llmops-k8s.yaml` file does not contain secrets. See [Kubernetes Secrets Security Guide](k8s-secrets-README.md) for handling API keys safely.

## 🤝 Contributing

Feel free to open issues or submit pull requests for improvements.

## 📊 Dataset

The anime dataset includes:
- Anime titles and descriptions
- Genres and ratings
- Synopsis information

The system uses this data to provide contextual recommendations based on user preferences.