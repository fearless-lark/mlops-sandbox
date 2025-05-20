"""Download data files if they do not exist locally."""
import os
import sys

# Add the project root (1 level up from the notebook) to sys.path
project_root = os.path.abspath(os.path.join(os.getcwd(), ".."))
if project_root not in sys.path:
    sys.path.append(project_root)

from utils import download_files


files_path = [
    "./data/raw/green_tripdata_2023-01.parquet",
    "./data/raw/green_tripdata_2023-02.parquet",
    "./data/raw/green_tripdata_2023-03.parquet",
    ]
urls = [
    "https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2023-01.parquet",
    "https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2023-02.parquet",
    "https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2023-03.parquet",
    ]

if __name__ == "__main__":
    # Download the files if they don"t exist
    download_files(files_path, urls)
