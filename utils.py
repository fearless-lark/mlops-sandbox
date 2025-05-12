'''Utility functions for downloading files and checking their existence.'''
import os
import pickle
import requests
import pandas as pd


def download_files(file_paths, urls):
    '''
    Downloads files from the given list of URLs if not already present locally.

    Args:
        file_paths (list of str): Local paths where files should be stored.
        urls (list of str): URLs to fetch the files from if not present locally.

    Returns:
        None
    '''
    if len(file_paths) != len(urls):
        raise ValueError('file_paths and urls must have the same length')

    for file_path, url in zip(file_paths, urls):
        os.makedirs(os.path.dirname(file_path), exist_ok=True)

        if not os.path.exists(file_path):
            print(f'{file_path} not found. Fetching from {url}...')
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                with open(file_path, 'wb') as f:
                    f.write(response.content)
                print(f'File downloaded and saved to {file_path}.')
            else:
                print(f'Failed to fetch the file from {url}. HTTP Status Code: {response.status_code}')
        else:
            print(f'File found locally at {file_path}.')


def read_dataframe(filename):
    '''
    Reads a CSV or Parquet file into a pandas DataFrame, processes the data,
    and returns the DataFrame.

    Args:
        filename (str): Path to the CSV or Parquet file.

    Returns:
        pd.DataFrame: Processed DataFrame with duration in minutes and categorical columns as strings.
    '''
    if filename.endswith('.csv'):
        df = pd.read_csv(filename)

        df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)
        df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
    elif filename.endswith('.parquet'):
        df = pd.read_parquet(filename)

    df['duration'] = df.lpep_dropoff_datetime - df.lpep_pickup_datetime
    df.duration = df.duration.apply(lambda td: td.total_seconds() / 60)

    df = df[(df.duration >= 1) & (df.duration <= 60)]

    categorical = ['PULocationID', 'DOLocationID']
    df[categorical] = df[categorical].astype(str)

    return df


def save_model(obj, path):
    '''
    Saves the given object to a file using pickle, ensuring the directory exists.

    Args:
        obj (Any): Object to serialize (e.g., a tuple like (dv, lr)).
        path (str): Path to the .bin file to save the object.
    '''
    # Ensure the directory exists
    os.makedirs(os.path.dirname(path), exist_ok=True)

    # Save the object
    with open(path, 'wb') as f_out:
        pickle.dump(obj, f_out)
    print(f'Model saved to {path}')
