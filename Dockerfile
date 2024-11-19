# Builder stage
FROM python:3.11-slim-buster as builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

# Create virtual environment and install build dependencies
RUN python -m venv $VIRTUAL_ENV && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        python3-dev \
        libpq-dev \
        libcairo2-dev \
        libpango1.0-dev \
        libgdk-pixbuf2.0-dev \
        libffi-dev \
        shared-mime-info \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Final stage
FROM python:3.11-slim-buster

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-cffi \
        python3-brotli \
        libpango-1.0-0 \
        libpangoft2-1.0-0 \
        libcairo2 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libgdk-pixbuf2.0-0 \
        shared-mime-info \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create unprivileged user and set up working directory
RUN adduser --disabled-password --no-create-home --gecos '' myuser && \
    mkdir -p /code && \
    chown -R myuser:myuser /code

WORKDIR /code

# Copy application code and scripts
COPY --chown=myuser:myuser . .

# Switch to unprivileged user
USER myuser

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8000/health/ || exit 1