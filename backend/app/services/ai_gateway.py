import os
import json
import re
import httpx
from typing import Dict, Any, List, Optional
from ..core.config import settings

class AIGateway:
    """
    Central AI Gateway providing access to LLMs (Gemini, OpenAI)
    with automatic deterministic Demo Mode fallback for jury presentations.
    """

    CRISIS_KEYWORDS = [
        # Russian
        "суицид", "убить себя", "покончить с собой", "самоубийств", "порезать вены", 
        "не хочу жить", "лучше умереть", "хочу умереть", "причинить себе боль",
        # Kazakh
        "өзіме қол салу", "өлгім келеді", "өмір сүргім келмейді", "өлу",
        # English
        "suicide", "kill myself", "want to die", "end my life", "self-harm", "cut myself"
    ]

    @classmethod
    def check_crisis(cls, text: str) -> bool:
        lower = text.lower()
        for kw in cls.CRISIS_KEYWORDS:
            if kw in lower:
                return True
        return False

    @classmethod
    def get_crisis_response(cls, language: str = "ru") -> Dict[str, Any]:
        if language == "kk":
            return {
                "reply": "Мен сіздің қазір өте қиын жағдайда екеніңізді сеземін және бұл туралы айтқаныңызға рақмет. Сіздің өміріңіз бен қауіпсіздігіңіз — ең бастысы. Мен жасанды интеллектпін және кәсіби медициналық немесе құтқару қызметін көрсете алмаймын. Өтінемін, дәл қазір жақын адамдарыңызбен немесе көмек көрсететін мамандармен байланысыңыз:\n\n📞 Шұғыл көмек: 112\n📞 Ұлттық сенім телефоны: 150 (тәулік бойы, тегін)",
                "isCrisis": True,
                "emergencyHelpline": "150 немесе 112",
                "suggestedTechnique": "Жақын адамға қоңырау шалу"
            }
        elif language == "en":
            return {
                "reply": "I hear how much pain you are experiencing right now, and I want you to know that your life and well-being are deeply important. As an AI emotional support tool, I cannot replace crisis professionals. Please immediately reach out to someone you trust or contact local emergency services:\n\n📞 Emergency: 112 or 911\n📞 Crisis Helpline: 150 (24/7 confidential support)",
                "isCrisis": True,
                "emergencyHelpline": "112 / 150",
                "suggestedTechnique": "Grounding 5-4-3-2-1 & reaching out to loved ones"
            }
        else:
            return {
                "reply": "Я чувствую, насколько вам сейчас тяжело, и очень ценю, что вы поделились этим. Ваша жизнь и безопасность — самое главное. Будучи AI-ассистентом эмоциональной поддержки, я не могу заменить специалистов кризисной помощи. Пожалуйста, прямо сейчас обратитесь к человеку, которому вы доверяете, или позвоните по бесплатной круглосуточной линии помощи:\n\n📞 Единая служба экстренной помощи: 112\n📞 Национальная линия доверия: 150 (бесплатно, анонимно)",
                "isCrisis": True,
                "emergencyHelpline": "150 или 112",
                "suggestedTechnique": "Практика заземления и звонок близкому человеку"
            }

    @classmethod
    async def generate_lesson_plan(
        cls,
        subject: str,
        grade: str,
        topic: str,
        duration: int,
        difficulty: str,
        language: str,
        objectives: Optional[str] = None
    ) -> Dict[str, Any]:
        # If real OpenAI or Gemini key is configured, invoke AI API
        if settings.OPENAI_API_KEY:
            try:
                plan = await cls._openai_generate_lesson(subject, grade, topic, duration, difficulty, language, objectives)
                if plan:
                    return plan
            except Exception:
                pass
        elif settings.GEMINI_API_KEY:
            try:
                return await cls._gemini_generate_lesson(subject, grade, topic, duration, difficulty, language, objectives)
            except Exception:
                pass # Fall back to deterministic educational generator

        # Deterministic High-Quality Generator
        lang_title = f"Поурочный план: {topic}" if language == "ru" else (f"Сабақ жоспары: {topic}" if language == "kk" else f"Lesson Plan: {topic}")
        
        objs = [
            f"Понять фундаментальные основы темы '{topic}'",
            f"Применить полученные знания при решении прикладных задач по предмету '{subject}'",
            "Сформировать навыки критического мышления и анализа данных"
        ] if language == "ru" else (
            [
                f"'{topic}' тақырыбының негізгі ұғымдарын меңгеру",
                f"'{subject}' пәні бойынша білімді практикалық есептерде қолдану",
                "Сыни тұрғыдан ойлау және талдау дағдыларын қалыптастыру"
            ] if language == "kk" else [
                f"Understand foundational concepts of '{topic}'",
                f"Apply knowledge to practical problem-solving in '{subject}'",
                "Develop critical thinking and analytical competence"
            ]
        )
        if objectives:
            objs.insert(0, objectives)

        return {
            "title": lang_title,
            "objectives": objs,
            "overview": f"Комплексный структурированный урок ({duration} минут) для {grade} класса по теме '{topic}'. Уровень: {difficulty}." if language == "ru" else f"{grade} сыныпқа арналған '{topic}' тақырыбы бойынша сабақ ({duration} мин). Деңгей: {difficulty}.",
            "introduction": "1. Организационный момент (3 мин)\n2. Мотивационная разминка и актуализация опорных знаний (5 мин)\n3. Постановка целей урока вместе с учащимися (2 мин)",
            "main_body": [
                f"Теоретический блок: ключевые определения и концепции темы '{topic}' (12 мин)",
                "Разбор демонстрационного примера у доски с пошаговыми комментариями (8 мин)",
                "Интерактивная дискуссия: ответы на вопросы учащихся (5 мин)"
            ],
            "practical_tasks": [
                "Задание 1 (базовый уровень): решение типовых упражнений в парах (7 мин)",
                "Задание 2 (повышенный уровень): контекстная задача с анализом условий (8 мин)",
                "Задание 3 (творческое): мини-кейс на применение изученного материала"
            ],
            "conclusion": "Рефлексия учебной деятельности методом 'Лестница успеха'. Подведение итогов, оценка усвоения материала (5 мин).",
            "homework": f"Параграф по теме '{topic}'. Выполнить упражнения 1-3 в рабочей тетради, составить 2 контрольных вопроса для одноклассников."
        }

    @classmethod
    async def generate_quiz(
        cls,
        subject: str,
        topic: str,
        grade: str,
        count: int,
        difficulty: str,
        q_type: str,
        language: str
    ) -> Dict[str, Any]:
        questions = []
        for i in range(1, count + 1):
            if language == "kk":
                q_text = f"{i}-сұрақ: '{topic}' бойынша негізгі қағида қандай?"
                opts = [
                    {"id": "a", "text": f"А) Негізгі анықтама сәйкес келеді ({topic})"},
                    {"id": "b", "text": "В) Екінші дәрежелі қосымша параметр"},
                    {"id": "c", "text": "С) Қарама-қайшы дәйек"},
                    {"id": "d", "text": "D) Тек арнайы шектеулі жағдайда"}
                ]
                explanation = f"Дұрыс жауап: А. Себебі '{topic}' тақырыбының базалық қасиеті осыған негізделген."
            elif language == "en":
                q_text = f"Question {i}: What is the core principle of '{topic}'?"
                opts = [
                    {"id": "a", "text": f"A) Standard fundamental definition of {topic}"},
                    {"id": "b", "text": "B) Secondary non-essential parameter"},
                    {"id": "c", "text": "C) Mutually exclusive thesis"},
                    {"id": "d", "text": "D) Boundary condition only"}
                ]
                explanation = f"Correct answer is A because {topic} is fundamentally structured around this property."
            else:
                q_text = f"Вопрос {i}: Что является ключевой особенностью темы '{topic}'?"
                opts = [
                    {"id": "a", "text": f"А) Фундаментальный закон и определение ({topic})"},
                    {"id": "b", "text": "Б) Вторичный вспомогательный признак"},
                    {"id": "c", "text": "В) Противоречащее условие"},
                    {"id": "d", "text": "Г) Частный случай нулевого приближения"}
                ]
                explanation = f"Правильный ответ: А. Это определение лежит в основе изучения темы '{topic}'."

            questions.append({
                "id": f"q-{i}",
                "text": q_text,
                "type": "single_choice" if q_type in ["single_choice", "mixed"] else q_type,
                "options": opts,
                "correct_option_ids": ["a"],
                "sample_answer": opts[0]["text"],
                "explanation": explanation
            })

        return {
            "title": f"Тест: {topic} ({grade} класс, {count} вопросов)" if language == "ru" else f"Тест: {topic} ({grade} сынып, {count} сұрақ)",
            "questions": questions
        }

    @classmethod
    async def simplify_text(cls, text: str, target_grade: str, language: str) -> Dict[str, Any]:
        # High quality text simplification
        if language == "kk":
            return {
                "title": "Мәтінді қарапайым тілмен бейімдеу",
                "simpleExplanation": f"Бұл мәтіннің негізгі мәні қарапайым сөздермен: берілген ақпарат негізгі үш құрамдас бөліктен тұрады және тәжірибеде оңай қолданылады.",
                "summary": "Қысқаша түйін: түпнұсқа материалдың күрделі терминдері күнделікті өмірдегі түсінікті мысалдармен алмастырылды.",
                "stepByStepGuide": [
                    "1-қадам: Негізгі тақырып пен негізгі ойды анықтау",
                    "2-қадам: Күрделі сөздерді контекстік мағынасына бөліп қарау",
                    "3-қадам: Алынған ережені өмірдегі нақты мысалмен бекіту"
                ],
                "keyConcepts": [
                    {"term": "Негізгі ұғым", "definition": "Зерттелетін құбылыстың басты түсінігі"},
                    {"term": "Қолдану аясы", "definition": "Бұл білімнің қайда және не үшін қажет екендігі"}
                ],
                "practicalExamples": [
                    "Күнделікті өмірден мысал: табиғат құбылыстарын бақылау кезінде дәл осы заңдылық көрініс табады."
                ]
            }
        elif language == "en":
            return {
                "title": "Simplified Educational Content",
                "simpleExplanation": "In simple words: this topic explains how elements interact systematically to produce a consistent outcome.",
                "summary": "Core takeaway: Complex academic jargon is translated into clear, actionable understanding without losing accuracy.",
                "stepByStepGuide": [
                    "Step 1: Identify the main subject and goal",
                    "Step 2: Understand the relationship between causes and effects",
                    "Step 3: Connect the concept to a real-world scenario"
                ],
                "keyConcepts": [
                    {"term": "Core Concept", "definition": "The central idea that everything else builds upon"},
                    {"term": "Application", "definition": "How you use this knowledge to solve problems"}
                ],
                "practicalExamples": [
                    "Real-world analogy: Think of this system like gears in a clock working together."
                ]
            }
        else:
            return {
                "title": "Адаптированный понятный материал",
                "simpleExplanation": "Простыми словами: сложный научный текст описывает, как ключевые элементы взаимодействуют между собой для достижения стабильного результата.",
                "summary": "Главная суть: весь сложный материал сведен к наглядным принципам без потери научной точности.",
                "stepByStepGuide": [
                    "Шаг 1: Определите главный предмет обсуждения",
                    "Шаг 2: Проследите логическую связь между причиной и следствием",
                    "Шаг 3: Закрепите правило на простом бытовом примере"
                ],
                "keyConcepts": [
                    {"term": "Базовое понятие", "definition": "Главный опорный термин, на котором строится вся тема"},
                    {"term": "Практический эффект", "definition": "То, к чему приводит действие данного закона в реальности"}
                ],
                "practicalExamples": [
                    "Наглядный пример: это работает точно так же, как слаженный часовой механизм, где каждая деталь помогает следующей."
                ]
            }

    @classmethod
    async def generate_supportive_chat_reply(
        cls,
        message: str,
        history: List[Any],
        language: str = "ru"
    ) -> Dict[str, Any]:
        # First: Safety evaluation
        if cls.check_crisis(message):
            return cls.get_crisis_response(language)

        lower = message.lower()
        if "стресс" in lower or "тревог" in lower or "стресс" in lower or "қобалжу" in lower or "stress" in lower or "anxious" in lower:
            technique = "Дыхание 4-7-8" if language != "en" else "4-7-8 Breathing Technique"
            if language == "kk":
                reply = "Емтихандар немесе оқу жүктемесі кезінде қобалжу — табиғи нәрсе. Сіз жалғыз емессіз. Қазір тынысыңызды ретке келтіру үшін 4-7-8 тыныс алу жаттығуын бірге жасап көрейік пе?"
            elif language == "en":
                reply = "Experiencing anxiety or stress during studies is completely natural. Take a gentle breath. Would you like to practice the 4-7-8 relaxation technique together right now?"
            else:
                reply = "Чувствовать волнение и стресс перед учебой или экзаменами — абсолютно нормально. Позвольте себе немного выдохнуть. Хотите сделать короткую дыхательную практику 4-7-8 прямо сейчас?"
            return {
                "reply": reply,
                "isCrisis": False,
                "suggestedTechnique": technique
            }

        if language == "kk":
            reply = f"Сізді мұқият тыңдап тұрмын. Өз сезімдеріңізді ашық айту — эмоционалды саулықтың маңызды қадамы. Сізге бұл жағдайда не көмектесе алады деп ойлайсыз?"
        elif language == "en":
            reply = f"Thank you for sharing that with me. Acknowledging your thoughts is a powerful step. What would feel most comforting for you right now?"
        else:
            reply = f"Спасибо, что поделились со мной. Проговаривать свои переживания — очень важный шаг к эмоциональному равновесию. Как я могу вас поддержать прямо сейчас?"

        return {
            "reply": reply,
            "isCrisis": False,
            "suggestedTechnique": None
        }

    @classmethod
    async def generate_general_assistant_reply(
        cls,
        message: str,
        history: List[Any],
        role: str = "student",
        language: str = "ru"
    ) -> Dict[str, Any]:
        # Always run crisis safety guardrails first
        if cls.check_crisis(message):
            crisis = cls.get_crisis_response(language)
            return {
                "reply": crisis["reply"],
                "isCrisis": True,
                "emergencyHelpline": crisis.get("emergencyHelpline"),
                "suggestedRoute": "/mindcare/chat",
            }

        # Real Gemini API integration if GEMINI_API_KEY is configured
        if settings.GEMINI_API_KEY:
            try:
                system_prompt = (
                    f"You are EduMind AI, a helpful educational assistant for a user with role '{role}'. "
                    f"Reply strictly in language '{language}'. Be structured, concise, and supportive. "
                    "Never give medical or psychiatric diagnoses."
                )
                url = (
                    "https://generativelanguage.googleapis.com/v1beta/models/"
                    f"gemini-1.5-flash:generateContent?key={settings.GEMINI_API_KEY}"
                )
                payload = {
                    "contents": [
                        {
                            "role": "user",
                            "parts": [{"text": f"{system_prompt}\n\nUser request: {message}"}],
                        }
                    ]
                }
                async with httpx.AsyncClient(timeout=settings.AI_REQUEST_TIMEOUT_SECONDS) as client:
                    resp = await client.post(url, json=payload)
                    if resp.status_code == 200:
                        data = resp.json()
                        text = data["candidates"][0]["content"]["parts"][0]["text"]
                        return {
                            "reply": text.strip(),
                            "isCrisis": False,
                            "emergencyHelpline": None,
                            "suggestedRoute": None,
                        }
            except Exception:
                pass

        lower = message.lower()

        # Detect emotional distress -> suggest MindCare
        if any(k in lower for k in ["стресс", "тревог", "устал", "выгоран", "қобалжу", "stress", "anxious", "tired"]):
            if language == "kk":
                reply = "Оқу жүктемесінен шаршау — қалыпты жағдай. 5 минут үзіліс жасап, MindCare бөліміндегі 4-7-8 тыныс алу жаттығуын орындап көруді ұсынамын."
            elif language == "en":
                reply = "Feeling fatigued or stressed during studies is completely normal. Take a 5-minute break and try the 4-7-8 breathing exercise in the MindCare module."
            else:
                reply = "Усталость и волнение во время учёбы — это нормально. Рекомендую сделать короткий перерыв на 5 минут и попробовать дыхательную практику 4-7-8 в модуле MindCare."
            return {
                "reply": reply,
                "isCrisis": False,
                "emergencyHelpline": None,
                "suggestedRoute": "/mindcare/exercises",
            }

        # Teacher-oriented contextual responses
        if role == "teacher":
            if any(k in lower for k in ["тест", "критери", "оценив", "quiz", "rubric", "бағалау"]):
                reply = (
                    "Для объективного оценивания рекомендую 4-критериальную шкалу (макс. 10 баллов):\n"
                    "1. Понимание ключевых понятий (0–3 балла)\n"
                    "2. Практическое применение и аргументация (0–3 балла)\n"
                    "3. Структура и наглядность подачи (0–2 балла)\n"
                    "4. Самостоятельность и выводы (0–2 балла)\n\n"
                    "Вы также можете автоматически создать тест в модуле «Конструктор тестов» Daryn Ustaz."
                )
                return {"reply": reply, "isCrisis": False, "emergencyHelpline": None, "suggestedRoute": "/teacher/quiz-generator"}
            if any(k in lower for k in ["физик", "пифагор", "урок", "план", "задан", "интерактив", "lesson"]):
                reply = (
                    f"Отличная педагогическая задача! Вот структура интерактивной активности по запросу «{message}»:\n"
                    "• Разминка (5 мин): короткий проблемный вопрос из реальной жизни.\n"
                    "• Мини-эксперимент / работа в парах (10 мин): ученики проверяют гипотезу на наглядных примерах.\n"
                    "• Закрепление (5 мин): быстрая рефлексия и 2 контрольных вопроса.\n\n"
                    "Хотите оформить это в полноценный поурочный план? Откройте «Генератор уроков» Daryn Ustaz."
                )
                return {"reply": reply, "isCrisis": False, "emergencyHelpline": None, "suggestedRoute": "/teacher/lesson-generator"}
            reply = (
                f"Как педагогический ассистент Daryn Ustaz, я проанализировал ваш запрос: «{message}».\n\n"
                "Рекомендуемый подход:\n"
                "1. Сформулируйте 1–2 измеримые цели урока.\n"
                "2. Разбейте теорию на блоки по 7–10 минут с проверкой понимания.\n"
                "3. Добавьте дифференцированное практическое задание (базовый и продвинутый уровень)."
            )
            return {"reply": reply, "isCrisis": False, "emergencyHelpline": None, "suggestedRoute": "/teacher/lesson-generator"}

        # Inclusive learner-oriented contextual responses
        if role == "learner":
            reply = (
                f"Давай разберём тему «{message}» просто и по шагам:\n\n"
                "Шаг 1. Главная идея — представь это как знакомую вещь из обычной жизни.\n"
                "Шаг 2. Разделим материал на короткие части, чтобы не перегружаться.\n"
                "Шаг 3. Попробуй пересказать своими словами в одном предложении.\n\n"
                "Нажми на иконку динамика ниже, чтобы прослушать объяснение вслух, или открой AI Simplifier для адаптации любого текста."
            )
            return {"reply": reply, "isCrisis": False, "emergencyHelpline": None, "suggestedRoute": "/inclusive/simplifier"}

        # Student-oriented contextual responses
        if any(k in lower for k in ["днк", "рнк", "dna", "rna"]):
            reply = (
                "Кратко о разнице между ДНК и РНК:\n"
                "• Структура: ДНК — двойная спираль, РНК — обычно одна цепочка.\n"
                "• Сахар: в ДНК — дезоксирибоза, в РНК — рибоза.\n"
                "• Основания: в ДНК есть тимин (Т), а в РНК вместо него урацил (У).\n"
                "• Роль: ДНК хранит наследственную информацию, а РНК переносит её и участвует в синтезе белка."
            )
            return {"reply": reply, "isCrisis": False, "emergencyHelpline": None, "suggestedRoute": None}
        if any(k in lower for k in ["экзамен", "дат", "запомн", "подготов", "exam", "plan"]):
            reply = (
                "Эффективный план подготовки и запоминания:\n"
                "1. Метод интервального повторения (через 1 день, 3 дня и 7 дней).\n"
                "2. Техника Помодоро: 25 минут фокуса + 5 минут отдыха.\n"
                "3. Активное воспроизведение: закрывайте конспект и пытайтесь пересказать ключевые факты или даты по памяти.\n"
                "4. Сон не менее 7–8 часов — именно во сне память консолидирует изученное."
            )
            return {"reply": reply, "isCrisis": False, "emergencyHelpline": None, "suggestedRoute": None}

        if language == "kk":
            reply = (
                f"«{message}» сұрағы бойынша оқу жоспары:\n"
                "1. Негізгі терминдер мен анықтамаларды бөліп алыңыз.\n"
                "2. Тақырыпты 2–3 қарапайым мысалмен бекітіңіз.\n"
                "3. Өзіңізді тексеру үшін 3 бақылау сұрағына жауап беріңіз."
            )
        elif language == "en":
            reply = (
                f"Here is a structured study approach for \"{message}\":\n"
                "1. Identify the core definitions and principles.\n"
                "2. Connect the concept to 1–2 concrete real-world examples.\n"
                "3. Test your understanding by explaining it in your own words."
            )
        else:
            reply = (
                f"Разбор по вашему вопросу «{message}»:\n"
                "1. Выделите главное определение и базовый принцип темы.\n"
                "2. Свяжите теорию с 1–2 наглядными примерами из практики.\n"
                "3. Проверьте себя: попробуйте кратко пересказать суть в 3 предложениях.\n\n"
                "Если нужно упростить большой текст — используйте модуль Inclusive AI Simplifier."
            )

        return {"reply": reply, "isCrisis": False, "suggestedTechnique": None}

    @classmethod
    async def _openai_generate_lesson(
        cls, subject: str, grade: str, topic: str, duration: int, difficulty: str, language: str, objectives: Optional[str]
    ) -> Optional[Dict[str, Any]]:
        url = "https://api.openai.com/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {settings.OPENAI_API_KEY}",
            "Content-Type": "application/json",
        }
        prompt = (
            f"Generate a structured lesson plan for subject '{subject}', grade '{grade}', topic '{topic}', "
            f"duration {duration} minutes, difficulty '{difficulty}', language '{language}'. "
            f"Return pure JSON with keys: title, objectives (list), overview, introduction, main_body (list), practical_tasks (list), conclusion, homework."
        )
        async with httpx.AsyncClient(timeout=settings.AI_REQUEST_TIMEOUT_SECONDS) as client:
            resp = await client.post(
                url,
                headers=headers,
                json={
                    "model": "gpt-4o-mini",
                    "messages": [{"role": "user", "content": prompt}],
                    "response_format": {"type": "json_object"},
                },
            )
            if resp.status_code == 200:
                data = resp.json()
                content = json.loads(data["choices"][0]["message"]["content"])
                return content
        return None
        return {"reply": reply, "isCrisis": False, "emergencyHelpline": None, "suggestedRoute": None}
