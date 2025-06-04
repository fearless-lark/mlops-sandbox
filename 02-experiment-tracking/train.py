import os
import pickle
import click
import mlflow

from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import root_mean_squared_error

# Import MLflow utility for .env configuration
from utils.mlflow_utils import setup_mlflow


def load_pickle(filename: str):
    with open(filename, "rb") as f_in:
        return pickle.load(f_in)


@click.command()
@click.option(
    "--data_path",
    default="./02-experiment-tracking/data/preprocessed/",
    help="Location where the processed NYC taxi trip data was saved"
)
def run_train(data_path: str):
    # Setup MLflow using environment variables from .env
    tracking_uri = setup_mlflow()
    print(f"Using MLflow tracking URI: {tracking_uri}")

    # Enable MLflow autologging
    mlflow.autolog()

    x_train, y_train = load_pickle(os.path.join(data_path, "train.pkl"))
    x_val, y_val = load_pickle(os.path.join(data_path, "val.pkl"))

    with mlflow.start_run():
        # Training
        rf = RandomForestRegressor(max_depth=10, random_state=0)
        rf.fit(x_train, y_train)

        # Evaluation
        y_pred = rf.predict(x_val)
        rmse = root_mean_squared_error(y_val, y_pred)

        # Log the RMSE metric manually (this is optional as autologging will capture most metrics)
        mlflow.log_metric("rmse", rmse)

        print(f"RMSE: {rmse}")


if __name__ == "__main__":
    run_train()
