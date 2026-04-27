import pytest
from app import app as flask_app, VERSION, APP_NAME

@pytest.fixture
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as c:
        yield c


def test_index_returns_json(client):
    r = client.get("/")
    assert r.status_code == 200
    data = r.get_json()
    assert data["service"] == APP_NAME
    assert data["version"] == VERSION
    assert "message" in data


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.get_json()["status"] == "ok"
