"""User endpoints tests."""


def _make_user(client, phone: str = "09120000020") -> dict:
    r = client.post("/auth/register", json={"phone": phone, "name": "Test"})
    otp = r.json()["dev_otp"]
    r = client.post(
        "/auth/verify-otp",
        json={"phone": phone, "code": otp, "password": "testpass123", "name": "Test"},
    )
    return r.json()


def _auth(tokens: dict) -> dict:
    return {"Authorization": f"Bearer {tokens['access_token']}"}


def test_get_me(client):
    tokens = _make_user(client, "09120000021")
    r = client.get("/users/me", headers=_auth(tokens))
    assert r.status_code == 200
    assert r.json()["phone"] == "09120000021"


def test_update_me(client):
    tokens = _make_user(client, "09120000022")
    r = client.patch(
        "/users/me",
        headers=_auth(tokens),
        json={"name": "New Name", "brief_hour": 8},
    )
    assert r.status_code == 200
    body = r.json()
    assert body["name"] == "New Name"
    assert body["brief_hour"] == 8


def test_update_me_rejects_invalid_brief_hour(client):
    tokens = _make_user(client, "09120000023")
    r = client.patch(
        "/users/me",
        headers=_auth(tokens),
        json={"brief_hour": 30},
    )
    assert r.status_code == 422


def test_set_tier_requires_admin(client):
    tokens = _make_user(client, "09120000024")
    r = client.post(
        "/users/1/tier",
        headers=_auth(tokens),
        json={"tier": "approved"},
    )
    # Non-admin user → 403
    assert r.status_code == 403


def test_me_without_token(client):
    r = client.get("/users/me")
    assert r.status_code == 401
