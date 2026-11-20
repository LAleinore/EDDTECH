# EduMind AI — Testing Guide

## 1. Backend Automated Tests (Pytest)

Run backend tests from the project root:
```bash
$env:PYTHONPATH = "backend"
python -m pytest backend/tests/ -v
```

### Covered Test Cases:
- `test_register_and_login`: User registration, duplicate email handling, JWT authentication, `/me` profile retrieval.
- `test_teacher_module_endpoints`: Lesson plan generation, interactive quiz creation with questions array, materials history listing.
- `test_mindcare_safety_and_mood`: Supportive conversational responses, deterministic crisis filter triggering hotline 112/150, mood entry creation, and mood trends summary.
- `test_inclusive_simplify`: Academic text simplification into key concepts and step-by-step guidance.

---

## 2. Flutter Mobile Tests & Analysis

Run static code analysis:
```bash
flutter analyze
```

Run mobile widget and unit tests:
```bash
flutter test
```

---

## 3. End-to-End User Scenarios Verification
1. **Teacher Scenario**:
   - Tap "Teacher Demo" on login screen.
   - Enter Home Dashboard -> tap "Генератор уроков".
   - Fill subject, grade, topic -> tap "Сгенерировать поурочный план".
   - View structured lesson plan and navigate to "История материалов".
2. **Student Scenario**:
   - Tap "Student Demo" on login screen.
   - Check in daily mood (4/5) with emotion tags -> view history.
   - Open MindCare chat -> type "Чувствую тревогу перед экзаменом" -> receive supportive guidance and 4-7-8 breathing practice shortcut.
   - Launch breathing timer -> complete 4 relaxation cycles.
3. **Learner (Inclusive) Scenario**:
   - Tap "Learner Demo" on login screen.
   - Notice automatically enlarged typography and high contrast mode.
   - Open "AI Simplifier" -> paste complex biology text -> tap "Упростить" -> tap speaker icon for TTS read-aloud.
   - Open "Голосовой ввод" -> record voice note with microphone -> view transcribed text.
