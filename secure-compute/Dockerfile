FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir cryptography

WORKDIR /compute
COPY worker.py .

CMD ["python", "-u", "worker.py"]
