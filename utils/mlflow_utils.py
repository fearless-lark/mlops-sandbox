"""
MLflow utilities for connecting to the tracking server
with environment variables loaded from .env file
"""
import os
from dotenv import load_dotenv
import mlflow

def setup_mlflow():
    """
    Set up MLflow tracking using environment variables from .env file
    """
    # Load environment variables from .env file
    load_dotenv()

    # Set tracking URI from environment variable
    tracking_uri = os.getenv('MLFLOW_TRACKING_URI', 'http://localhost:5000')
    mlflow.set_tracking_uri(tracking_uri)

    return tracking_uri
