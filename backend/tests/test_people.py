"""People module tests."""


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


def test_create_person(client):
    t = _make_user(client, "09120010301")
    r = client.post(
        "/people",
        headers=_h(t),
        json={"name": "Ali", "phone": "09121111111", "relationship": "friend"},
    )
    assert r.status_code == 201
    body = r.json()
    assert body["name"] == "Ali"
    assert body["relationship"] == "friend"


def test_invalid_relationship_rejected(client):
    t = _make_user(client, "09120010302")
    r = client.post(
        "/people",
        headers=_h(t),
        json={"name": "X", "relationship": "enemy"},
    )
    assert r.status_code == 422


def test_birthday_countdown(client):
    from datetime import date, timedelta

    t = _make_user(client, "09120010303")
    future = (date.today() + timedelta(days=5)).isoformat()
    r = client.post(
        "/people",
        headers=_h(t),
        json={"name": "Bday", "birthday": future},
    )
    assert r.status_code == 201
    assert r.json()["days_until_birthday"] == 5


def test_upcoming_birthdays(client):
    from datetime import date, timedelta

    t = _make_user(client, "09120010304")
    soon = (date.today() + timedelta(days=3)).isoformat()
    later = (date.today() + timedelta(days=45)).isoformat()
    client.post("/people", headers=_h(t), json={"name": "Soon", "birthday": soon})
    client.post("/people", headers=_h(t), json={"name": "Later", "birthday": later})

    r = client.get("/people/birthdays?within_days=30", headers=_h(t))
    assert r.status_code == 200
    assert len(r.json()) == 1
    assert r.json()[0]["person"]["name"] == "Soon"


def test_update_person(client):
    t = _make_user(client, "09120010305")
    pid = client.post("/people", headers=_h(t), json={"name": "Old"}).json()["id"]
    r = client.patch(f"/people/{pid}", headers=_h(t), json={"nickname": "Oldie"})
    assert r.status_code == 200
    assert r.json()["nickname"] == "Oldie"


def test_delete_person(client):
    t = _make_user(client, "09120010306")
    pid = client.post("/people", headers=_h(t), json={"name": "Temp"}).json()["id"]
    assert client.delete(f"/people/{pid}", headers=_h(t)).status_code == 204
    assert client.get("/people", headers=_h(t)).json() == []


def test_people_isolation_between_users(client):
    t1 = _make_user(client, "09120010307")
    t2 = _make_user(client, "09120010308")
    pid = client.post("/people", headers=_h(t1), json={"name": "Private"}).json()["id"]
    assert client.get(f"/people/{pid}", headers=_h(t2)).status_code == 404


def test_people_require_auth(client):
    assert client.get("/people").status_code == 401
