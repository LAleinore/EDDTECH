# EduMind AI — Database Architecture & Schema

PostgreSQL 15+ / Supabase Schema.

## Tables

### 1. `profiles`
Stores user profile information, roles, and accessibility preferences.
- `id` (UUID, Primary Key)
- `email` (VARCHAR(255), Unique, Indexed)
- `name` (VARCHAR(255))
- `hashed_password` (VARCHAR(255))
- `role` (VARCHAR(50), Indexed) — `teacher`, `student`, `learner`, `admin`
- `language` (VARCHAR(10)) — `ru`, `kk`, `en`
- `accessibility_settings` (JSONB)
- `is_demo` (BOOLEAN)
- `created_at` (TIMESTAMPTZ)
- `last_login_at` (TIMESTAMPTZ)

### 2. `teacher_materials`
Stores lesson plans, quizzes, and concept explanations.
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key -> `profiles.id`)
- `title` (VARCHAR(255))
- `material_type` (VARCHAR(50)) — `lesson_plan`, `quiz`, `concept_explanation`
- `subject` (VARCHAR(100))
- `grade` (VARCHAR(50))
- `topic` (VARCHAR(255))
- `content` (JSONB)
- `created_at` (TIMESTAMPTZ)

### 3. `mood_entries`
Stores daily emotional check-ins.
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key -> `profiles.id`)
- `score` (INT, 1-5)
- `mood_state` (VARCHAR(50))
- `emotions` (JSONB)
- `note` (TEXT)
- `created_at` (TIMESTAMPTZ)

### 4. `mindcare_chat_messages`
Stores conversation history with crisis tracking.
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key -> `profiles.id`)
- `role` (VARCHAR(20))
- `content` (TEXT)
- `is_crisis` (BOOLEAN)
- `created_at` (TIMESTAMPTZ)

### 5. `inclusive_materials`
Stores adapted materials and simplified texts.
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key -> `profiles.id`)
- `title` (VARCHAR(255))
- `original_text` (TEXT)
- `simplified_content` (JSONB)
- `language` (VARCHAR(10))
- `created_at` (TIMESTAMPTZ)

## Security
All tables enforce Row Level Security (RLS) guaranteeing that students, teachers, and learners can only access their own respective private data.
