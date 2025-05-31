#!/usr/bin/env python
"""Setup script for the MLOps Sandbox package."""

from setuptools import setup, find_packages

# Read requirements from requirements.txt
with open("requirements.txt", "r", encoding="utf-8") as f:
    requirements = [line.strip() for line in f if not line.startswith("//")]

setup(
    name="mlops-sandbox",
    version="0.1.0",
    description="MLOps Zoomcamp Sandbox project for learning MLOps concepts",
    author="fearless-lark",
    author_email="user@example.com",
    python_requires=">=3.12",
    packages=find_packages(),
    install_requires=requirements,
    license="MIT",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.12",
    ],
)
