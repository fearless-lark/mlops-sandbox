"""Download data files if they do not exist locally."""
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
