-- EduMind AI: Complete PostgreSQL Initial Schema
-- Supports Supabase / Direct PostgreSQL with UUIDs, indexes, and timestamps

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'student', -- teacher, student, learner, admin
    avatar_url VARCHAR(500) DEFAULT '',
    language VARCHAR(10) NOT NULL DEFAULT 'ru',
    accessibility_settings JSONB NOT NULL DEFAULT '{
        "fontScale": 1.0,
        "highContrast": false,
        "reduceMotion": false,
        "voiceEnabled": false,
        "simplifiedUI": false,
        "largeButtons": false
    }'::jsonb,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_demo BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- 2. Teacher Materials Table (Lesson plans, concepts)
CREATE TABLE IF NOT EXISTS teacher_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    material_type VARCHAR(50) NOT NULL, -- lesson_plan, quiz, concept_explanation
    subject VARCHAR(100) NOT NULL,
    grade VARCHAR(50) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    language VARCHAR(10) NOT NULL DEFAULT 'ru',
    content JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_teacher_materials_user_id ON teacher_materials(user_id);
CREATE INDEX IF NOT EXISTS idx_teacher_materials_subject ON teacher_materials(subject);

-- 3. Mood Tracker Entries
CREATE TABLE IF NOT EXISTS mood_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    score INT NOT NULL CHECK (score >= 1 AND score <= 5),
    mood_state VARCHAR(50) NOT NULL, -- terrible, bad, neutral, good, excellent
    emotions JSONB NOT NULL DEFAULT '[]'::jsonb,
    note TEXT DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mood_entries_user_id ON mood_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_entries_created_at ON mood_entries(created_at DESC);

-- 4. MindCare Supportive Chat Messages
CREATE TABLE IF NOT EXISTS mindcare_chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL, -- user, assistant, system
    content TEXT NOT NULL,
    is_crisis BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mindcare_chat_user_id ON mindcare_chat_messages(user_id);

-- 5. Inclusive AI Materials
CREATE TABLE IF NOT EXISTS inclusive_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    original_text TEXT NOT NULL,
    simplified_content JSONB NOT NULL,
    language VARCHAR(10) NOT NULL DEFAULT 'ru',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_inclusive_materials_user_id ON inclusive_materials(user_id);

-- 6. AI Usage Analytics (Anonymous Rate Limits & Token Tracking)
CREATE TABLE IF NOT EXISTS ai_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    module VARCHAR(50) NOT NULL, -- teacher, mindcare, inclusive
    prompt_tokens INT DEFAULT 0,
    completion_tokens INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
