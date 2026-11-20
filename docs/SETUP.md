# EduMind AI — Setup and Run Guide

## Prerequisites
- **Flutter SDK**: 3.32+ (Dart 3.8+)
- **Python**: 3.12+
- **PostgreSQL**: 15+ (or SQLite local fallback for rapid development)
- **Xcode / iOS Simulator**: (for iOS build & real iPhone deployment via macOS)

---

## 1. Backend Setup

1. Open terminal in `backend/` directory:
   ```bash
   cd backend
   python -m venv venv
   # Windows:
   .\venv\Scripts\activate
   # Linux/macOS:
   source venv/bin/activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Configure environment:
   ```bash
   cp ../.env.example .env
   ```

4. Run database migrations / initialization:
   ```bash
   python -m app.core.database
   ```

5. Run the FastAPI development server:
   ```bash
   uvicorn app.main:app --reload --port 8000 --host 0.0.0.0
   ```
   Interactive Swagger docs available at `http://localhost:8000/docs`.

---

## 2. Flutter Mobile Application

1. Open root project directory:
   ```bash
   flutter pub get
   ```

2. Run code analysis:
   ```bash
   flutter analyze
   ```

3. Run automated tests:
   ```bash
   flutter test
   ```

4. Launch application:
   - In Chrome (Web preview):
     ```bash
     flutter run -d chrome
     ```
   - On iOS Simulator / Device (macOS):
     ```bash
     flutter run -d iphone
     ```

---

## 3. Demo Mode (Zero-Config Jury Presentation)
EduMind AI includes a comprehensive, 100% deterministic Demo Mode that works without requiring external database or AI API keys:
- Preset demo accounts:
  - **Teacher Demo**: `teacher@edumind.ai`
  - **Student Demo**: `student@edumind.ai`
  - **Learner Demo**: `learner@edumind.ai`
- Tap the **Demo Mode** button on the login screen to enter immediately as any of the three roles with pre-populated educational, mood, and accessibility data.
