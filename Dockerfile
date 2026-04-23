FROM node:20-slim AS tailwind-builder
WORKDIR /build
COPY tailwind.config.js tailwind.input.css ./
COPY app/templates ./app/templates
COPY app/static/js ./app/static/js
RUN npx --yes tailwindcss -i tailwind.input.css -o tailwind.output.css --minify

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
COPY --from=tailwind-builder /build/tailwind.output.css /app/app/static/css/tailwind.css

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]
