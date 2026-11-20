import pytest

@pytest.mark.asyncio
async def test_register_and_login(client):
    # 1. Register new teacher
    reg_payload = {
        "name": "Айгүл Серікқызы",
        "email": "teacher@edumind.ai",
        "password": "Password123!",
        "role": "teacher",
        "language": "ru"
    }
    reg_res = await client.post("/api/auth/register", json=reg_payload)
    assert reg_res.status_code == 201, reg_res.text
    reg_data = reg_res.json()
    assert "token" in reg_data
    assert reg_data["user"]["email"] == "teacher@edumind.ai"
    assert reg_data["user"]["role"] == "teacher"

    # 2. Duplicate registration should fail
    dup_res = await client.post("/api/auth/register", json=reg_payload)
    assert dup_res.status_code == 400

    # 3. Login with correct password
    login_res = await client.post("/api/auth/login", json={
        "email": "teacher@edumind.ai",
        "password": "Password123!"
    })
    assert login_res.status_code == 200
    login_data = login_res.json()
    token = login_data["token"]
    assert token

    # 4. Login with bad password should fail
    bad_login = await client.post("/api/auth/login", json={
        "email": "teacher@edumind.ai",
        "password": "wrongpassword"
    })
    assert bad_login.status_code == 401

    # 5. Access /me with token
    me_res = await client.get("/api/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert me_res.status_code == 200
    assert me_res.json()["email"] == "teacher@edumind.ai"
