"""Tags module tests."""


def _make_user(client, phone: str) -> dict:
    r = client.post("/auth/register", json={"phone": phone, "name": "T"})
    otp = r.json()["dev_otp"]
    r = client.post(
        "/auth/verify-otp",
        json={"phone": phone, "code": otp, "password": "testpass123", "name": "T"},
    )
    return r.json()


def _h(tokens: dict) -> dict:
    return {"Authorization": f"Bearer {tokens['access_token']}"}


def test_create_tag(client):
    t = _make_user(client, "09120010101")
    r = client.post("/tags", headers=_h(t), json={"name": "work", "color": "#5AA9E6"})
    assert r.status_code == 201
    assert r.json()["name"] == "work"


def test_strip_at_prefix(client):
    t = _make_user(client, "09120010102")
    r = client.post("/tags", headers=_h(t), json={"name": "@home"})
    assert r.status_code == 201
    assert r.json()["name"] == "home"


def test_duplicate_tag_rejected(client):
    t = _make_user(client, "09120010103")
    client.post("/tags", headers=_h(t), json={"name": "work"})
    r = client.post("/tags", headers=_h(t), json={"name": "work"})
    assert r.status_code == 409


def test_list_tags_sorted(client):
    t = _make_user(client, "09120010104")
    for name in ["zebra", "alpha", "mango"]:
        client.post("/tags", headers=_h(t), json={"name": name})
    r = client.get("/tags", headers=_h(t))
    names = [x["name"] for x in r.json()]
    assert names == ["alpha", "mango", "zebra"]


def test_delete_tag(client):
    t = _make_user(client, "09120010105")
    tid = client.post("/tags", headers=_h(t), json={"name": "temp"}).json()["id"]
    r = client.delete(f"/tags/{tid}", headers=_h(t))
    assert r.status_code == 204
    assert client.get("/tags", headers=_h(t)).json() == []


def test_tag_isolation_between_users(client):
    t1 = _make_user(client, "09120010106")
    t2 = _make_user(client, "09120010107")
    tid = client.post("/tags", headers=_h(t1), json={"name": "personal"}).json()["id"]
    r = client.patch(f"/tags/{tid}", headers=_h(t2), json={"name": "hijack"})
    assert r.status_code == 404
