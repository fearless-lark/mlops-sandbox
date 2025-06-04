import os
import pickle
import click
import mlflow
import numpy as np
from hyperopt import STATUS_OK, Trials, fmin, hp, tpe
from hyperopt.pyll import scope
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import root_mean_squared_error

# Import MLflow utility for .env configuration
from utils.mlflow_utils import setup_mlflow

# Set up MLflow tracking with .env configuration
setup_mlflow()
mlflow.set_experiment("random-forest-hyperopt-env")


def load_pickle(filename: str):
    with open(filename, "rb") as f_in:
        return pickle.load(f_in)


@click.command()
@click.option(
    "--data_path",
    default="./02-experiment-tracking/data/preprocessed/",
    help="Location where the processed NYC taxi trip data was saved"
)
@click.option(
    "--num_trials",
    default=15,
    help="The number of parameter evaluations for the optimizer to explore"
)
def run_optimization(data_path: str, num_trials: int):

    x_train, y_train = load_pickle(os.path.join(data_path, "train.pkl"))
    x_val, y_val = load_pickle(os.path.join(data_path, "val.pkl"))

    def objective(params):
        with mlflow.start_run():
            # Log all parameters
            mlflow.log_params(params)

            # Train the model with these parameters
            rf = RandomForestRegressor(**params)
            rf.fit(x_train, y_train)

            # Make predictions and calculate RMSE
            y_pred = rf.predict(x_val)
            rmse = root_mean_squared_error(y_val, y_pred)

            # Log the validation RMSE metric
            mlflow.log_metric("rmse", rmse)

            return {"loss": rmse, "status": STATUS_OK}

    search_space = {
        "max_depth": scope.int(hp.quniform("max_depth", 1, 20, 1)),
        "n_estimators": scope.int(hp.quniform("n_estimators", 10, 50, 1)),
        "min_samples_split": scope.int(hp.quniform("min_samples_split", 2, 10, 1)),
        "min_samples_leaf": scope.int(hp.quniform("min_samples_leaf", 1, 4, 1)),
        "random_state": 42
    }

    rstate = np.random.default_rng(42)  # for reproducible results
    fmin(
        fn=objective,
        space=search_space,
        algo=tpe.suggest,
        max_evals=num_trials,
        trials=Trials(),
        rstate=rstate
    )


if __name__ == "__main__":
    run_optimization()
