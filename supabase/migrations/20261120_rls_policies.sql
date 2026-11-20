-- Row Level Security (RLS) Policies for EduMind AI
-- Enforces data isolation so users cannot read or write others' private records

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE mood_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE mindcare_chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE inclusive_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_usage ENABLE ROW LEVEL SECURITY;

-- 1. Profiles: users can select and update their own profile
CREATE POLICY "Users can read own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

-- 2. Teacher Materials: teachers can only manage their own materials
CREATE POLICY "Users can read own teacher materials"
    ON teacher_materials FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own teacher materials"
    ON teacher_materials FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own teacher materials"
    ON teacher_materials FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own teacher materials"
    ON teacher_materials FOR DELETE
    USING (auth.uid() = user_id);

-- 3. Mood Tracker: strictly private to the user
CREATE POLICY "Users can read own mood entries"
    ON mood_entries FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own mood entries"
    ON mood_entries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own mood entries"
    ON mood_entries FOR DELETE
    USING (auth.uid() = user_id);

-- 4. MindCare Chat: strictly private psychological conversations
CREATE POLICY "Users can read own chat messages"
    ON mindcare_chat_messages FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat messages"
    ON mindcare_chat_messages FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat messages"
    ON mindcare_chat_messages FOR DELETE
    USING (auth.uid() = user_id);

-- 5. Inclusive Materials: strictly private to user
CREATE POLICY "Users can read own inclusive materials"
    ON inclusive_materials FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own inclusive materials"
    ON inclusive_materials FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own inclusive materials"
    ON inclusive_materials FOR DELETE
    USING (auth.uid() = user_id);
