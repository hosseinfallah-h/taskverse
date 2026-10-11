"""Pytest fixtures."""

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture(scope="session")
def client():
    """Test client for the FastAPI app."""
    with TestClient(app) as c:
        yield c