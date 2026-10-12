"""Auth flow tests."""


def _register(client, phone: str = "09120000010"):
    r = client.post("/auth/register", json={"phone": phone, "name": "Test"})
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["ok"] is True
    assert body["dev_otp"], "expected dev_otp in DEBUG"
    return body["dev_otp"]


def _verify(client, phone: str, otp: str, password: str = "testpass123"):
    r = client.post(
        "/auth/verify-otp",
        json={
            "phone": phone,
            "code": otp,
            "password": password,
            "name": "Test",
        },
    )
    assert r.status_code == 200, r.text
    return r.json()


def test_register_returns_dev_otp(client):
    otp = _register(client, "09120000011")
    assert otp.isdigit() and len(otp) == 6


def test_verify_otp_creates_user_and_returns_tokens(client):
    phone = "09120000012"
    otp = _register(client, phone)
    tokens = _verify(client, phone, otp)
    assert "access_token" in tokens
    assert "refresh_token" in tokens
    assert tokens["token_type"] == "bearer"


def test_me_requires_token(client):
    r = client.get("/auth/me")
    assert r.status_code == 401


def test_me_with_token_returns_user(client):
    phone = "09120000013"
    otp = _register(client, phone)
    tokens = _verify(client, phone, otp)
    r = client.get("/auth/me", headers={"Authorization": f"Bearer {tokens['access_token']}"})
    assert r.status_code == 200
    body = r.json()
    assert body["phone"] == phone
    assert body["tier"] == "pending"


def test_login_with_password(client):
    phone = "09120000014"
    otp = _register(client, phone)
    _verify(client, phone, otp, password="mypassword123")
    r = client.post("/auth/login", json={"phone": phone, "password": "mypassword123"})
    assert r.status_code == 200
    assert "access_token" in r.json()


def test_login_wrong_password(client):
    phone = "09120000015"
    otp = _register(client, phone)
    _verify(client, phone, otp, password="rightpassword")
    r = client.post("/auth/login", json={"phone": phone, "password": "wrongpassword"})
    assert r.status_code == 401


def test_verify_otp_bad_code(client):
    phone = "09120000016"
    _register(client, phone)
    r = client.post(
        "/auth/verify-otp",
        json={"phone": phone, "code": "000000", "password": "testpass123", "name": "X"},
    )
    assert r.status_code == 400


def test_refresh_token_rotation(client):
    phone = "09120000017"
    otp = _register(client, phone)
    tokens = _verify(client, phone, otp)
    r = client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r.status_code == 200
    new_tokens = r.json()
    assert "access_token" in new_tokens
    assert new_tokens["refresh_token"] != tokens["refresh_token"]

    # Old refresh token should now be revoked
    r2 = client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r2.status_code == 401
