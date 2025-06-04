# MLOps Zoomcamp Sandbox
Original course is [here](https://github.com/DataTalksClub/mlops-zoomcamp/tree/main).

## Run project locally
1. Install Python

Recommended version of Python is 3.12.6

2. Prepare developing environment
Install [conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) or [virtualenv](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/) on your machine.

Virtualenv is more preferred for this project. So the instructions below are from virtualenv setup on Unix/MacOS machines.

If you're willing to use Conda and/or Windows, please refer to the official documentation ([conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html), [virtualenv](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/)).

3. Clone project repository locally
```bash
git clone https://github.com/fearless-lark/mlops-sandbox.git
```

4. Move to a project folder locally
```bash
cd mlops-sandbox
```

5. Create virtual environment for the projects
```bash
python3 -m venv .venv
```

6. Activating a virtual environment
```bash
source .venv/bin/activate
```

7. Install project dependencies
```bash
uv pip install --upgrade pip
uv pip install -e .
uv pip install -r requirements.txt
```

## Linting and Code Checks
To ensure consistent code quality and styling, this project employs pylint as a linting tool. Regular linting helps identify and fix potential issues in the codebase, leading to more readable and maintainable code.

To run the linter, use the following command:
```
pylint $(git ls-files '*.py')
```

## MLFlow

### MLflow Configuration with .env File

MLflow is configured via a `.env` file in the project root. Make sure to set these variables:

```properties
# MLflow configuration
MLFLOW_SERVER_HOST=0.0.0.0         # Host address for the MLflow server
MLFLOW_SERVER_PORT=5005            # Port for the MLflow server
MLFLOW_BACKEND_STORE_URI=sqlite:///mlflow.db  # Database for metadata
MLFLOW_DEFAULT_ARTIFACT_ROOT=./mlruns        # Artifact storage location
MLFLOW_TRACKING_URI=http://localhost:5005    # Client connection URI
```

A template file `.env.sample` is provided in the repository. Copy it to create your own `.env` file:

```bash
cp .env.sample .env
```

### Running MLflow with Docker

To run MLflow using Docker:

1. Make sure you have Docker and Docker Compose installed on your system
2. Use the provided management script:

```bash
# Interactive menu mode (recommended)
./scripts/mlflow_manager.sh

# Or use specific commands
./scripts/mlflow_manager.sh start    # Start MLflow server
./scripts/mlflow_manager.sh status   # Check status
./scripts/mlflow_manager.sh logs     # View logs
./scripts/mlflow_manager.sh stop     # Stop MLflow server
```

3. Access the MLflow UI at http://localhost:5005

### Using MLflow in your code

When using MLflow in your code, use the utility function to load the configuration:

```python
from utils.mlflow_utils import setup_mlflow

# Load config from .env
setup_mlflow()

# Use MLflow as usual
```

### Running MLflow locally
```
mlflow ui --port 5005 --backend-store-uri sqlite:///mlflow.db --default-artifact-root ./mlruns
```