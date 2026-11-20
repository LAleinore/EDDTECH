-- EduMind AI Seed Data for Demo Mode Presentation

-- 1. Teacher Demo Profile
INSERT INTO profiles (
    id, email, name, hashed_password, role, language, is_demo, created_at
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    'teacher@edumind.ai',
    'Айгүл Серікқызы',
    'd8578edf8458ce06fbc5bb76a58c5ca4',
    'teacher',
    'ru',
    true,
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- 2. Student Demo Profile
INSERT INTO profiles (
    id, email, name, hashed_password, role, language, is_demo, created_at
) VALUES (
    '00000000-0000-0000-0000-000000000002',
    'student@edumind.ai',
    'Алихан Нуртаев',
    'd8578edf8458ce06fbc5bb76a58c5ca4',
    'student',
    'ru',
    true,
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- 3. Learner Demo Profile (with Accessibility settings)
INSERT INTO profiles (
    id, email, name, hashed_password, role, language, accessibility_settings, is_demo, created_at
) VALUES (
    '00000000-0000-0000-0000-000000000003',
    'learner@edumind.ai',
    'Данияр Бекенов',
    'd8578edf8458ce06fbc5bb76a58c5ca4',
    'learner',
    'ru',
    '{
        "fontScale": 1.25,
        "highContrast": true,
        "reduceMotion": true,
        "voiceEnabled": true,
        "simplifiedUI": true,
        "largeButtons": true
    }'::jsonb,
    true,
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Pre-seed Teacher Material
INSERT INTO teacher_materials (
    id, user_id, title, material_type, subject, grade, topic, language, content
) VALUES (
    '00000000-0000-0000-0001-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Поурочный план: Законы Ньютона',
    'lesson_plan',
    'Физика',
    '9',
    'Законы Ньютона',
    'ru',
    '{
        "title": "Поурочный план: Законы Ньютона",
        "objectives": ["Изучить три закона динамики Ньютона", "Научиться применять F=ma для решения прикладных задач"],
        "overview": "Базовый 45-минутный урок для 9 класса",
        "introduction": "Организационный момент (3 мин), разминка (5 мин)",
        "main_body": ["Теоретический блок (12 мин)", "Демонстрация опыта (8 мин)"],
        "practical_tasks": ["Решение типовых задач у доски", "Работа в парах с карточками"],
        "conclusion": "Рефлексия и опрос",
        "homework": "Параграф 14, задачи 1-3"
    }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- Pre-seed Mood Entry
INSERT INTO mood_entries (
    id, user_id, score, mood_state, emotions, note, created_at
) VALUES (
    '00000000-0000-0000-0002-000000000001',
    '00000000-0000-0000-0000-000000000002',
    4,
    'good',
    '["Спокойствие", "Вдохновение"]'::jsonb,
    'Отличная подготовка к контрольной работе',
    NOW()
) ON CONFLICT (id) DO NOTHING;
