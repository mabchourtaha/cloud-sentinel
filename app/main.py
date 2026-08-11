import logging
import os

import boto3
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, UploadFile

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("cloud-sentinel")

app = FastAPI()

BUCKET_NAME = os.environ.get("S3_BUCKET_NAME")
AWS_REGION = os.environ.get("AWS_REGION", "eu-west-1")

s3_client = boto3.client("s3", region_name=AWS_REGION)


@app.get("/health")
def health():
    logger.info("Health check requested")
    return {"status": "ok"}


@app.post("/upload")
async def upload_file(file: UploadFile):
    logger.info(f"Upload requested: {file.filename}")
    try:
        s3_client.upload_fileobj(file.file, BUCKET_NAME, file.filename)
    except Exception as e:
        logger.error(f"Upload failed: {e}")
        raise HTTPException(status_code=500, detail="Upload failed")
    return {"filename": file.filename, "status": "uploaded"}


@app.get("/files")
def list_files():
    logger.info("File list requested")
    try:
        response = s3_client.list_objects_v2(Bucket=BUCKET_NAME)
        files = [obj["Key"] for obj in response.get("Contents", [])]
    except Exception as e:
        logger.error(f"List failed: {e}")
        raise HTTPException(status_code=500, detail="Could not list files")
    return {"files": files}

