FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim as runtime
RUN useradd -m -u 1000 appuser
WORKDIR /app
COPY --from=builder /root/.local /home/appuser/.local
COPY src/ ./src
ENV PATH=/home/appuser/.local/bin:$PATH
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:80/')" || exit 1
CMD ["gunicorn", "--bind", "0.0.0.0:80", "--workers", "2", "src.app:app"]
