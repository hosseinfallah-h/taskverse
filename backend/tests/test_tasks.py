"""Tasks module tests."""
from datetime import UTC


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


def test_create_task(client):
    t = _make_user(client, "09120010201")
    r = client.post(
        "/tasks",
        headers=_h(t),
        json={"title": "Buy milk", "priority": 2, "energy": "low"},
    )
    assert r.status_code == 201
    body = r.json()
    assert body["title"] == "Buy milk"
    assert body["status"] == "todo"
    assert body["priority"] == 2
    assert body["subtasks_count"] == 0


def test_subtask_creation(client):
    t = _make_user(client, "09120010202")
    parent = client.post("/tasks", headers=_h(t), json={"title": "Parent"}).json()
    r = client.post(
        "/tasks",
        headers=_h(t),
        json={"title": "Sub", "parent_id": parent["id"]},
    )
    assert r.status_code == 201
    assert r.json()["parent_id"] == parent["id"]

    # Parent now reports 1 subtask
    r = client.get(f"/tasks/{parent['id']}", headers=_h(t))
    assert r.json()["subtasks_count"] == 1
    assert r.json()["subtasks_done"] == 0


def test_subtask_depth_limited(client):
    t = _make_user(client, "09120010203")
    a = client.post("/tasks", headers=_h(t), json={"title": "A"}).json()
    b = client.post("/tasks", headers=_h(t), json={"title": "B", "parent_id": a["id"]}).json()
    c = client.post("/tasks", headers=_h(t), json={"title": "C", "parent_id": b["id"]}).json()
    # Depth 3 should be rejected
    r = client.post("/tasks", headers=_h(t), json={"title": "D", "parent_id": c["id"]})
    assert r.status_code == 400


def test_status_change_to_done(client):
    t = _make_user(client, "09120010204")
    tid = client.post("/tasks", headers=_h(t), json={"title": "x"}).json()["id"]
    r = client.post(f"/tasks/{tid}/status", headers=_h(t), json={"status": "done"})
    assert r.status_code == 200
    assert r.json()["status"] == "done"
    assert r.json()["completed_at"] is not None


def test_view_today(client):
    from datetime import date

    t = _make_user(client, "09120010205")
    today_iso = date.today().isoformat()
    client.post(
        "/tasks", headers=_h(t), json={"title": "today", "due_date": today_iso}
    )
    client.post("/tasks", headers=_h(t), json={"title": "no due"})
    r = client.get("/tasks?view=today", headers=_h(t))
    assert len(r.json()) == 1
    assert r.json()[0]["title"] == "today"


def test_soft_delete_and_restore(client):
    t = _make_user(client, "09120010206")
    tid = client.post("/tasks", headers=_h(t), json={"title": "temp"}).json()["id"]
    assert client.delete(f"/tasks/{tid}", headers=_h(t)).status_code == 204
    assert client.get(f"/tasks/{tid}", headers=_h(t)).status_code == 404

    r = client.post(f"/tasks/{tid}/restore", headers=_h(t))
    assert r.status_code == 200
    assert r.json()["id"] == tid


def test_defer_hides_from_list(client):
    from datetime import datetime, timedelta

    t = _make_user(client, "09120010207")
    tid = client.post("/tasks", headers=_h(t), json={"title": "defer me"}).json()["id"]

    future = (datetime.now(UTC) + timedelta(days=3)).isoformat()
    r = client.post(f"/tasks/{tid}/defer", headers=_h(t), json={"deferred_until": future})
    assert r.status_code == 200

    r = client.get("/tasks", headers=_h(t))
    ids = [x["id"] for x in r.json()]
    assert tid not in ids


def test_task_with_tags(client):
    t = _make_user(client, "09120010208")
    tag_id = client.post("/tags", headers=_h(t), json={"name": "urgent"}).json()["id"]
    tid = client.post(
        "/tasks",
        headers=_h(t),
        json={"title": "tagged", "tag_ids": [tag_id]},
    ).json()["id"]
    r = client.get(f"/tasks/{tid}", headers=_h(t))
    assert len(r.json()["tags"]) == 1
    assert r.json()["tags"][0]["name"] == "urgent"


def test_task_isolation_between_users(client):
    t1 = _make_user(client, "09120010209")
    t2 = _make_user(client, "09120010210")
    tid = client.post("/tasks", headers=_h(t1), json={"title": "private"}).json()["id"]
    assert client.get(f"/tasks/{tid}", headers=_h(t2)).status_code == 404


def test_tasks_require_auth(client):
    assert client.get("/tasks").status_code == 401
