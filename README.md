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
