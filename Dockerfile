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

# Install UV package manager and verify installation
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo "UV installed at:" && \
    find /root -name uv -type f 2>/dev/null || echo "UV not found"

# Add UV to PATH
ENV PATH="/root/.local/bin:/root/.cargo/bin:$PATH"

# Copy dependency files first (for better caching)
COPY pyproject.toml ./
COPY README.md ./

# Install Python dependencies
# First try to find UV, then use it or fall back to pip
RUN if command -v uv >/dev/null 2>&1; then \
        echo "Using UV" && \
        uv venv && \
        . .venv/bin/activate && \
        uv pip install -e .; \
    else \
        echo "UV not found, using pip" && \
        pip install --no-cache-dir -e .; \
    fi

# Copy the rest of the application
COPY . .

# Create directories for logs and vector store
RUN mkdir -p logs chroma_db

# Expose Streamlit port
EXPOSE 8501

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Set Python path to include the app directory
ENV PYTHONPATH=/app:$PYTHONPATH

# Run the app using UV environment
CMD ["/app/.venv/bin/streamlit", "run", "app/app.py", \
     "--server.port=8501", \
     "--server.address=0.0.0.0", \
     "--server.headless=true", \
     "--server.fileWatcherType=none"]