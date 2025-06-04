#!/usr/bin/env python
# coding: utf-8
"""
Dagster orchestration for the NYC taxi trip duration prediction workflow.
"""
# import pickle
# from pathlib import Path
import pandas as pd
# import xgboost as xgb
# from sklearn.feature_extraction import DictVectorizer
from sklearn.metrics import root_mean_squared_error
import mlflow
from dagster import job, op, In, Out, graph, AssetMaterialization, MetadataValue, AssetKey

from utils.utils import download_files, read_dataframe, preprocess_dataframe, save_model
from utils.mlflow_utils import setup_mlflow


files_path = [
    "./03-orchestration/data/yellow_tripdata_2023-01.parquet",
    "./03-orchestration/data/yellow_tripdata_2023-02.parquet",
    "./03-orchestration/data/yellow_tripdata_2023-03.parquet"
    ]
urls = [
    "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-01.parquet",
    "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-02.parquet",
    "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-03.parquet"
    ]
download_files(files_path, urls)


@op(out={"df": Out(is_required=True)})
def fetch_data(taxi_color: str, year: int, month: int):
    """Fetch NYC Taxi data using the external read_dataframe function."""
    filename = f"./03-orchestration/data/{taxi_color}_tripdata_{year}-{month:02d}.parquet"
    df = read_dataframe(filename)
    print(f"Loaded dataframe with shape: {df.shape}")
    return df


@op(ins={"df": In(pd.DataFrame)}, out=Out(pd.DataFrame, is_required=True))
def preprocess_data(df: pd.DataFrame):
    """Preprocess the DataFrame to create feature matrix and target variable."""
    df = preprocess_dataframe(df)
    print(f"Processed dataframe with shape: {df.shape}")
    return df


# @op(ins={"val_df": In(), "dv": In()}, out={"x_val": Out(is_required=True), "y_val": Out(is_required=True)})
# def preprocess_validation_data(val_df, dv):
#     """Create validation feature matrix using the same DictVectorizer."""
#     categorical = ["PU_DO"]
#     numerical = ["trip_distance"]
#     dicts = val_df[categorical + numerical].to_dict(orient="records")

#     x_val = dv.transform(dicts)

#     target = "duration"
#     y_val = val_df[target].values

#     return x_val, y_val


# @op(ins={"x_train": In(), "y_train": In(), "x_val": In(), "y_val": In(), "dv": In()})
# def train_model(x_train, y_train, x_val, y_val, dv, context=None):
#     """Train XGBoost model and log with MLflow."""
#     # Set up MLflow tracking
#     setup_mlflow()
#     mlflow.set_experiment("nyc-taxi-experiment")

#     # Create models folder if it doesn"t exist
#     models_folder = Path("models")
#     models_folder.mkdir(exist_ok=True)

#     with mlflow.start_run() as mlflow_run:
#         train = xgb.DMatrix(x_train, label=y_train)
#         valid = xgb.DMatrix(x_val, label=y_val)

#         best_params = {
#             "learning_rate": 0.09585355369315604,
#             "max_depth": 30,
#             "min_child_weight": 1.060597050922164,
#             "objective": "reg:linear",
#             "reg_alpha": 0.018060244040060163,
#             "reg_lambda": 0.011658731377413597,
#             "seed": 42
#         }

#         mlflow.log_params(best_params)

#         booster = xgb.train(
#             params=best_params,
#             dtrain=train,
#             num_boost_round=30,
#             evals=[(valid, "validation")],
#             early_stopping_rounds=50
#         )

#         y_pred = booster.predict(valid)
#         rmse = root_mean_squared_error(y_val, y_pred)
#         mlflow.log_metric("rmse", rmse)

#         with open("models/preprocessor.b", "wb") as f_out:
#             pickle.dump(dv, f_out)
#         mlflow.log_artifact("models/preprocessor.b", artifact_path="preprocessor")

#         mlflow.xgboost.log_model(booster, artifact_path="models_mlflow")

#         run_id = mlflow_run.info.run_id

#         # Yield an asset materialization to track the model as an asset
#         yield AssetMaterialization(
#             asset_key=AssetKey("taxi_duration_model"),
#             description="XGBoost model for taxi duration prediction",
#             metadata={
#                 "mlflow_run_id": MetadataValue.text(run_id),
#                 "rmse": MetadataValue.float(rmse)
#             },
#         )

#         if context:
#             context.log.info(f"MLflow run_id: {run_id}")
#         else:
#             print(f"MLflow run_id: {run_id}")

#         # Write run_id to a file
#         with open("run_id.txt", "w", encoding="utf-8") as f:
#             f.write(run_id)


@graph
def taxi_duration_prediction_pipeline():
    """Graph function that connects the operations into a pipeline."""
    # Training data
    # We'll use config for the fetch_data op instead of passing parameters directly
    df_train = fetch_data()
    # x_train, dv, y_train = preprocess_data(df_train)

    # # Validation data (next month)
    # next_year = year if month < 12 else year + 1
    # next_month = month + 1 if month < 12 else 1
    # df_val = read_dataframe(next_year, next_month)
    # x_val, y_val = preprocess_validation_data(df_val, dv)

    # # Train model
    # train_model(x_train=x_train, y_train=y_train, x_val=x_val, y_val=y_val, dv=dv)


@job
def taxi_duration_prediction_job():
    """Job that executes the taxi duration prediction pipeline."""
    taxi_duration_prediction_pipeline()


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Train a model to predict taxi trip duration using Dagster.")
    parser.add_argument("--taxi-color", type=str, default="yellow", help="Taxi color (yellow or green)")
    parser.add_argument("--year", type=int, default=2023, help="Year of the data to train on")
    parser.add_argument("--month", type=int, default=3, help="Month of the data to train on")
    args = parser.parse_args()

    # Set job configuration with command line arguments
    job_config = {
        "ops": {
            "taxi_duration_prediction_pipeline": {
                "ops": {
                    "fetch_data": {
                        "inputs": {
                            "taxi_color": args.taxi_color,
                            "year": args.year,
                            "month": args.month
                        }
                    }
                }
            }
        }
    }

    # Execute the job with the config
    taxi_duration_prediction_job.execute_in_process(run_config=job_config)
