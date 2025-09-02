# Use Python 3.10 slim image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install UV package manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add UV to PATH
ENV PATH="/root/.cargo/bin:$PATH"

# Copy dependency files first (for better caching)
COPY pyproject.toml ./

# Install Python dependencies using UV
# This will generate uv.lock if it doesn't exist
RUN /root/.cargo/bin/uv venv && \
    . .venv/bin/activate && \
    /root/.cargo/bin/uv pip install -e .

# Copy the rest of the application
COPY . .

# Create directories for logs and vector store
RUN mkdir -p logs chroma_db

# Expose Streamlit port
EXPOSE 8501

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Run the app using UV environment
CMD ["/app/.venv/bin/streamlit", "run", "app/app.py", \
     "--server.port=8501", \
     "--server.address=0.0.0.0", \
     "--server.headless=true", \
     "--server.fileWatcherType=none"]