# EduMind AI Architecture

## 1. System Overview
EduMind AI is an intelligent educational mobile ecosystem for iOS integrating three key pillars:
1. **Daryn Ustaz** - AI Assistant for educators (curriculum generation, quiz creation, topic explanation, materials history).
2. **MindCare** - Student emotional and psychological well-being support with a dedicated deterministic safety layer, mood tracking, relaxation and breathing practices.
3. **Inclusive AI** - Accessible and adaptive education (TTS, STT, text simplifier, document processing, dynamic typography, high contrast).

```
+-------------------------------------------------------------+
|                 EduMind AI iOS Application                  |
|  - Material 3 / Cupertino Theme                             |
|  - Riverpod State Management                                |
|  - GoRouter Navigation & Role Guard                         |
|  - Storage: FlutterSecureStorage + SharedPreferences        |
|  - Audio/Voice: flutter_tts + speech_to_text                |
+------------------------------+------------------------------+
                               | HTTPS / REST (Dio)
                               v
+-------------------------------------------------------------+
|                  FastAPI Backend Engine                     |
|  - Auth & Role-Based Access (Teacher/Student/Learner/Admin) |
|  - Module Routers: /teacher, /mindcare, /inclusive, /profile|
|  - Pydantic Validation & Security Headers                   |
|  - Safety Guardrails Layer (MindCare Safety Interceptor)    |
+------------------------------+------------------------------+
                               |
               +---------------+---------------+
               |                               |
               v                               v
+------------------------------+ +----------------------------+
|  PostgreSQL / Supabase DB    | |         AI Gateway         |
|  - Profiles & Settings       | |  - Provider Router         |
|  - Teacher Materials & Tests | |  - Gemini / OpenAI APIs    |
|  - Mood Entries & Stats      | |  - Deterministic Demo Fall |
|  - Inclusive Transcriptions  | |  - Rate Limit & Retry      |
+------------------------------+ +----------------------------+
```

## 2. Directory Structure

### Flutter Client (`lib/`)
- `app/`: Application lifecycle, routing (`router.dart`), themes (`theme/`), localization (`localization/`).
- `core/`: Config, networking (`api_client.dart`), storage, common reusable widgets, audio services.
- `features/auth/`: Registration, login, password recovery, session handling, Demo Mode personas.
- `features/home/`: Dynamic Home Dashboard adapted for Teacher, Student, and Learner.
- `features/teacher/`: Daryn Ustaz modules (lesson planning, quiz generator, conceptual explanations, history).
- `features/mindcare/`: MindCare chat with safety filters, mood tracker with weekly/monthly charts, breathing practices.
- `features/inclusive/`: TTS, STT, AI simplifier, accessibility settings (font scale, high contrast, reduced motion).
- `features/ai_assistant/`: Unified AI assistant router respecting user role context.
- `features/profile/`: Profile editor, role switcher, language selector, data consent management.

### Backend (`backend/`)
- `app/core/`: Configuration, JWT security, database engine.
- `app/api/`: Main API router and dependency injection.
- `app/models/`: SQLAlchemy ORM models with UUID primary keys and foreign keys.
- `app/schemas/`: Strict Pydantic models for request/response validation.
- `app/repositories/`: Data access layer isolating business logic from storage.
- `app/services/`: AI Gateway, Safety Evaluator, Teacher Service, MindCare Service, Inclusive Service.
- `app/modules/`: API endpoint route handlers for each module.
- `tests/`: Pytest test suite covering authentication, data isolation, safety rules, and AI Gateway fallback.

### Database & Migrations (`supabase/migrations/`)
- PostgreSQL schema with UUID keys, indexes, timestamps, and RLS (Row Level Security) ensuring users can only read and mutate their own private data.
