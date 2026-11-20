import pytest

@pytest.mark.asyncio
async def test_teacher_module_endpoints(client):
    # Register teacher
    reg_res = await client.post("/api/auth/register", json={
        "name": "Тест Учитель",
        "email": "teacher_test@edumind.ai",
        "password": "Password123!",
        "role": "teacher",
        "language": "ru"
    })
    token = reg_res.json()["token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Generate lesson
    lesson_res = await client.post("/api/teacher/lesson", headers=headers, json={
        "subject": "Физика",
        "grade": "9",
        "topic": "Законы Ньютона",
        "duration_minutes": 45,
        "difficulty": "medium",
        "language": "ru"
    })
    assert lesson_res.status_code == 200, lesson_res.text
    lesson_data = lesson_res.json()
    assert "content" in lesson_data
    assert len(lesson_data["content"]["objectives"]) > 0

    # 2. Generate quiz
    quiz_res = await client.post("/api/teacher/quiz", headers=headers, json={
        "subject": "Физика",
        "topic": "Законы Ньютона",
        "grade": "9",
        "questions_count": 3,
        "difficulty": "medium",
        "question_type": "single_choice",
        "language": "ru"
    })
    assert quiz_res.status_code == 200
    quiz_data = quiz_res.json()
    assert len(quiz_data["content"]["questions"]) == 3

    # 3. Get history
    history_res = await client.get("/api/teacher/history", headers=headers)
    assert history_res.status_code == 200
    items = history_res.json()
    assert len(items) >= 2

@pytest.mark.asyncio
async def test_mindcare_safety_and_mood(client):
    reg_res = await client.post("/api/auth/register", json={
        "name": "Тест Студент",
        "email": "student_test@edumind.ai",
        "password": "Password123!",
        "role": "student",
        "language": "ru"
    })
    token = reg_res.json()["token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Normal supportive chat
    chat_res = await client.post("/api/mindcare/chat", headers=headers, json={
        "message": "Привет! Я немного переживаю из-за завтрашнего экзамена по математике.",
        "language": "ru"
    })
    assert chat_res.status_code == 200
    assert chat_res.json()["isCrisis"] is False

    # 2. Safety filter: Crisis keyword detection triggers emergency protocol
    crisis_res = await client.post("/api/mindcare/chat", headers=headers, json={
        "message": "Мне очень плохо, я не хочу жить и думаю о суициде",
        "language": "ru"
    })
    assert crisis_res.status_code == 200
    crisis_data = crisis_res.json()
    assert crisis_data["isCrisis"] is True
    assert "112" in crisis_data["reply"]
    assert "150" in crisis_data["reply"]

    # 3. Create mood entry
    mood_res = await client.post("/api/mindcare/mood", headers=headers, json={
        "score": 4,
        "moodState": "good",
        "emotions": ["Спокойствие", "Уверенность"],
        "note": "Хороший день!"
    })
    assert mood_res.status_code == 200
    assert mood_res.json()["score"] == 4

    # 4. Get mood stats
    stats_res = await client.get("/api/mindcare/mood/statistics", headers=headers)
    assert stats_res.status_code == 200
    assert stats_res.json()["totalEntries"] >= 1

@pytest.mark.asyncio
async def test_inclusive_simplify(client):
    reg_res = await client.post("/api/auth/register", json={
        "name": "Тест Ученик",
        "email": "learner_test@edumind.ai",
        "password": "Password123!",
        "role": "learner",
        "language": "ru"
    })
    token = reg_res.json()["token"]
    headers = {"Authorization": f"Bearer {token}"}

    simplify_res = await client.post("/api/inclusive/simplify", headers=headers, json={
        "text": "Фотосинтез представляет собой сложный химический процесс преобразования энергии видимого света в химическую энергию органических веществ при участии хлорофилла.",
        "target_grade": "elementary",
        "language": "ru"
    })
    assert simplify_res.status_code == 200
    data = simplify_res.json()
    assert "simplified" in data
    assert len(data["simplified"]["stepByStepGuide"]) > 0

@pytest.mark.asyncio
async def test_general_ai_assistant(client):
    reg_res = await client.post("/api/auth/register", json={
        "name": "Тест Ассистент",
        "email": "assistant_test@edumind.ai",
        "password": "Password123!",
        "role": "teacher",
        "language": "ru"
    })
    token = reg_res.json()["token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Pedagogical question
    res = await client.post("/api/assistant/chat", headers=headers, json={
        "message": "Как объяснить теорему Пифагора интерактивно?",
        "role": "teacher",
        "language": "ru"
    })
    assert res.status_code == 200
    data = res.json()
    assert data["isCrisis"] is False
    assert len(data["reply"]) > 20

    # Crisis guardrail in general assistant
    crisis_res = await client.post("/api/assistant/chat", headers=headers, json={
        "message": "я не хочу жить",
        "role": "student",
        "language": "ru"
    })
    assert crisis_res.status_code == 200
    assert crisis_res.json()["isCrisis"] is True
    assert "112" in crisis_res.json()["reply"]
