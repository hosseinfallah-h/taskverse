"""Smoke tests for health + meta endpoints."""

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root_returns_ok():
    r = client.get("/")
    assert r.status_code == 200
    data = r.json()
    assert data["status"] == "ok"
    assert "version" in data


def test_health_returns_healthy():
    r = client.get("/health")
    assert r.status_code == 200
    data = r.json()
    assert data["status"] == "healthy"
    assert data["app"] == "TaskVerse"


def test_meta_info():
    r = client.get("/meta/info")
    assert r.status_code == 200
    data = r.json()
    assert data["name"] == "TaskVerse"
    assert "version" in data