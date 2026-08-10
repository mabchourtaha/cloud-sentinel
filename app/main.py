import logging
import os

from dotenv import load_dotenv
from fastapi import FastAPI

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("cloud-sentinel")

app = FastAPI()

BUCKET_NAME = os.environ.get("S3_BUCKET_NAME")
AWS_REGION = os.environ.get("AWS_REGION", "eu-west-1")

@app.get("/health")
def health():
    logger.info("Health check requested")
    return {"status": "ok"}