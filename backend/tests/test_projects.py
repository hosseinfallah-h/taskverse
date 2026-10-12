"""Projects module tests."""


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


def test_create_and_list_projects(client):
    t = _make_user(client, "09120010001")
    r = client.post(
        "/projects",
        headers=_h(t),
        json={"name": "Content Channel", "color": "#0F5132", "icon": "camera"},
    )
    assert r.status_code == 201, r.text
    body = r.json()
    assert body["name"] == "Content Channel"
    assert body["color"] == "#0F5132"

    r = client.get("/projects", headers=_h(t))
    assert r.status_code == 200
    assert len(r.json()) == 1


def test_update_project(client):
    t = _make_user(client, "09120010002")
    pid = client.post("/projects", headers=_h(t), json={"name": "Old"}).json()["id"]
    r = client.patch(f"/projects/{pid}", headers=_h(t), json={"name": "New"})
    assert r.status_code == 200
    assert r.json()["name"] == "New"


def test_soft_delete_project(client):
    t = _make_user(client, "09120010003")
    pid = client.post("/projects", headers=_h(t), json={"name": "DeleteMe"}).json()["id"]
    r = client.delete(f"/projects/{pid}", headers=_h(t))
    assert r.status_code == 204
    r = client.get("/projects", headers=_h(t))
    assert len(r.json()) == 0


def test_project_isolation_between_users(client):
    t1 = _make_user(client, "09120010004")
    t2 = _make_user(client, "09120010005")
    pid = client.post("/projects", headers=_h(t1), json={"name": "Mine"}).json()["id"]
    r = client.get(f"/projects/{pid}", headers=_h(t2))
    assert r.status_code == 404


def test_projects_require_auth(client):
    r = client.get("/projects")
    assert r.status_code == 401
