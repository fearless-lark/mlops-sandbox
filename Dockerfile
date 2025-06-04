FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -U pip
RUN pip install -r requirements.txt

COPY . .

# Make port available to the world outside this container
EXPOSE ${MLFLOW_SERVER_PORT}

ENTRYPOINT ["sh", "-c", "mlflow server --host ${MLFLOW_SERVER_HOST} --port ${MLFLOW_SERVER_PORT} --backend-store-uri ${MLFLOW_BACKEND_STORE_URI} --default-artifact-root ${MLFLOW_DEFAULT_ARTIFACT_ROOT}"]
