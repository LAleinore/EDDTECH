# EduMind AI — API Reference

Base URL: `http://localhost:8000/api`

## 1. Authentication (`/auth`)

### `POST /auth/register`
Creates a new user profile.
- **Request Body**:
  ```json
  {
    "name": "Айгүл Серікқызы",
    "email": "teacher@edumind.ai",
    "password": "Password123!",
    "role": "teacher",
    "language": "ru"
  }
  ```
- **Response** `201 Created`:
  ```json
  {
    "token": "eyJhbGciOi...",
    "token_type": "bearer",
    "user": {
      "id": "uuid",
      "name": "Айгүл Серікқызы",
      "email": "teacher@edumind.ai",
      "role": "teacher",
      "language": "ru",
      "accessibility": { "fontScale": 1.0, "highContrast": false }
    }
  }
  ```

### `POST /auth/login`
Authenticates existing user with email and password.
- **Request Body**: `{"email": "...", "password": "..."}`
- **Response** `200 OK`: `{"token": "...", "user": {...}}`

### `GET /auth/me`
Returns the currently authenticated user based on the Bearer JWT.

---

## 2. Daryn Ustaz Teacher AI (`/teacher`)

### `POST /teacher/lesson`
Generates a structured lesson plan.
- **Request Body**:
  ```json
  {
    "subject": "Физика",
    "grade": "9",
    "topic": "Законы Ньютона",
    "duration_minutes": 45,
    "difficulty": "medium",
    "language": "ru"
  }
  ```

### `POST /teacher/quiz`
Generates an interactive multi-question quiz.
- **Request Body**:
  ```json
  {
    "subject": "Физика",
    "topic": "Законы динамики",
    "grade": "9",
    "questions_count": 5,
    "question_type": "single_choice"
  }
  ```

### `GET /teacher/history`
Retrieves all curriculum materials created by the authenticated educator.

---

## 3. MindCare Emotional Support (`/mindcare`)

### `POST /mindcare/chat`
Supportive conversational endpoint with deterministic Safety Guardrails.
- If crisis or self-harm keywords are detected, returns `isCrisis: true` and urgent contact instructions for 112 / 150.
- **Request Body**:
  ```json
  {
    "message": "Чувствую стресс перед экзаменом",
    "language": "ru"
  }
  ```

### `POST /mindcare/mood`
Logs a mood check-in (score 1-5, emotions array, optional note).

### `GET /mindcare/mood/statistics`
Returns weekly and monthly trends and average score.

---

## 4. Inclusive AI (`/inclusive`)

### `POST /inclusive/simplify`
Simplifies complex academic text into clear explanations, bullet points, and key terms.
