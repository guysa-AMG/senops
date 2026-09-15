FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home --home-dir /app appuser

WORKDIR /app
COPY --chown=appuser:appuser . /app
USER appuser

CMD ["python", "--version"]
