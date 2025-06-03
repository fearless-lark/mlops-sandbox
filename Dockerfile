FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -U pip
RUN pip install -r requirements.txt

COPY . .

# Make port 5005 available to the world outside this container
EXPOSE 5005

ENTRYPOINT ["mlflow", "server", "--host", "0.0.0.0", "--port", "5005", "--backend-store-uri", "sqlite:///mlflow.db", "--default-artifact-root", "./mlruns"]
