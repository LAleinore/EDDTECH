import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/ai_service.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/inclusive_material_model.dart';

final inclusiveRepositoryProvider = Provider<InclusiveRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final aiService = ref.watch(aiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return InclusiveRepository(
    apiClient: apiClient,
    aiService: aiService,
    prefs: prefs,
  );
});

class InclusiveRepository {
  final ApiClient _apiClient;
  final AiService _aiService;
  final SharedPreferences _prefs;

  InclusiveRepository({
    required ApiClient apiClient,
    required AiService aiService,
    required SharedPreferences prefs,
  })  : _apiClient = apiClient,
        _aiService = aiService,
        _prefs = prefs;

  static const String _materialsKey = 'inclusive_saved_materials_v1';

  Future<SimplifiedResultModel> simplifyText({
    required String text,
    String targetGrade = 'elementary',
    String language = 'ru',
  }) async {
    // 1. Live AI simplification via AiService
    try {
      final prompt =
          'Ты — вдохновляющий учитель и популяризатор науки Inclusive AI.\n'
          'Твоя задача — объяснить тему или сложный учебный материал максимально понятно, увлекательно и наглядно для школьника ($targetGrade уровень).\n'
          'Материал или тема: "$text"\n'
          'Язык ответа: ${language == 'kk' ? 'казахский' : 'русский'}\n'
          'Если передан короткий термин или тема (например, "ядерная физика", "гравитация", "фотосинтез", "теорема Пифагора"), подробно раскрой её суть простыми словами и метафорами (как для ребенка: что это, из чего состоит, как работает, пример из жизни).\n'
          'Ответь строго валидным JSON со следующей структурой без markdown:\n'
          '{\n'
          '  "title": "Понятный заголовок темы",\n'
          '  "simpleExplanation": "Подробное и живое объяснение простыми словами и метафорами (3-5 предложений)",\n'
          '  "summary": "Главная суть в 1-2 простых предложениях",\n'
          '  "stepByStepGuide": ["Шаг 1: ...", "Шаг 2: ...", "Шаг 3: ..."],\n'
          '  "keyConcepts": [\n'
          '    {"term": "Понятие 1", "definition": "Простое определение"},\n'
          '    {"term": "Понятие 2", "definition": "Простое определение"}\n'
          '  ],\n'
          '  "practicalExamples": ["Наглядный пример или жизненная аналогия"],\n'
          '  "videoTitle": "Название познавательного обучающего видео по теме",\n'
          '  "videoQuery": "Поисковый запрос для поиска видео на YouTube"\n'
          '}';

      final aiText = await _aiService.completePrompt(
        prompt,
        systemPrompt:
            'Ты чуткий и вдохновляющий учитель Inclusive AI. Твоя миссия — сделать любую сложную научную или школьную концепцию кристально ясной, интересной и наглядной для каждого ребенка. Отвечай исключительно валидным JSON.',
        temperature: 0.5,
      );

      final dynamic parsed = AiService.parseJsonSafely(aiText);
      if (parsed is Map<String, dynamic>) {
        final concepts = (parsed['keyConcepts'] as List?)
                ?.map((c) => KeyConceptModel(
                      term: c['term']?.toString() ?? '',
                      definition: c['definition']?.toString() ?? '',
                    ))
                .toList() ??
            [];

        final topicTitle = parsed['title']?.toString() ?? 'Адаптированный материал';
        final query = parsed['videoQuery']?.toString() ?? topicTitle;
        final vUrl =
            'https://www.youtube.com/results?search_query=${Uri.encodeComponent('$query детям анимация')}';

        final result = SimplifiedResultModel(
          title: topicTitle,
          simpleExplanation: parsed['simpleExplanation']?.toString() ?? '',
          summary: parsed['summary']?.toString() ?? '',
          stepByStepGuide: (parsed['stepByStepGuide'] as List?)
                  ?.map((s) => s.toString())
                  .toList() ??
              [],
          keyConcepts: concepts,
          practicalExamples: (parsed['practicalExamples'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          videoTitle: parsed['videoTitle']?.toString() ?? 'Видеоурок: $topicTitle (Анимация)',
          videoUrl: vUrl,
        );

        _saveLocalMaterial(text, result);
        return result;
      }
    } catch (_) {}

    // 2. Try Backend API
    try {
      final res = await _apiClient.dio.post(
        '/inclusive/simplify',
        data: {'text': text, 'target_grade': targetGrade, 'language': language},
      );

      final map = res.data['simplified'] as Map<String, dynamic>;
      final result = SimplifiedResultModel.fromMap(map);
      _saveLocalMaterial(text, result);
      return result;
    } catch (_) {
      // 3. Contextual Educational Fallback
      return _buildContextualFallback(text, language);
    }
  }

  SimplifiedResultModel _buildContextualFallback(String text, String language) {
    final lower = text.toLowerCase();

    // 1. Ядерная физика / Атомная энергия
    if (lower.contains('ядерн') || lower.contains('атом') || lower.contains('ядро')) {
      return SimplifiedResultModel(
        title: 'Ядерная физика: удивительная сила внутри атома',
        simpleExplanation:
            'Всё вокруг нас — воздух, вода, горы и мы сами — сложено из крошечных невидимых шариков-атомов. '
            'В самом центре каждого атома находится сверхплотное ядро, словно ядро в персике. '
            'Ядерная физика изучает невероятную силу, удерживающую эти частицы вместе: если ядро аккуратно разделить или слить два легких ядра, '
            'выделяется фантастическая энергия, которая зажигает звезды и дарит электричество целым городам!',
        summary:
            'Ядерная физика изучает крошечное ядро атома и гигантскую чистую энергию, скрытую внутри него.',
        stepByStepGuide: [
          'Шаг 1: Представь атом как маленькую планетную систему: электроны кружатся вокруг центрального ядра.',
          'Шаг 2: В ядре плотно прижаты друг к другу протоны и нейтроны.',
          'Шаг 3: На АЭС ядро урана делится нейтроном — выделяется много тепла, которое крутит турбины генераторов.',
        ],
        keyConcepts: [
          KeyConceptModel(
            term: 'Атомное ядро',
            definition: 'Самая плотная сердцевина атома, где сосредоточена почти вся его масса и энергия.',
          ),
          KeyConceptModel(
            term: 'Протоны и Нейтроны',
            definition: 'Элементарные частицы-кирпичики, из которых построено ядро любого вещества.',
          ),
          KeyConceptModel(
            term: 'Ядерная энергия',
            definition: 'Мощная чистая энергия, выделяющаяся при делении тяжелых или слиянии легких ядер.',
          ),
        ],
        practicalExamples: [
          'Живой пример: наше Солнце и все звезды в космосе светят миллиарды лет благодаря ядерной энергии термоядерного синтеза!',
        ],
        videoTitle: 'Обучающий мультфильм: Как устроен атом и ядерная энергия простыми словами',
        videoUrl:
            'https://www.youtube.com/results?search_query=%D1%8F%D0%B4%D0%B5%D1%80%D0%BD%D0%B0%D1%8F+%D1%84%D0%B8%D0%B7%D0%B8%D0%BA%D0%B0+%D0%B4%D0%B5%D1%82%D1%8F%D0%BC+%D0%B0%D0%BD%D0%B8%D0%BC%D0%B0%D1%86%D0%B8%D1%8F',
      );
    }

    // 2. Фотосинтез
    if (lower.contains('фотосинтез') || lower.contains('хлорофилл')) {
      return SimplifiedResultModel(
        title: 'Как растения делают себе еду (Фотосинтез)',
        simpleExplanation:
            'Фотосинтез — это природная «зеленая кухня» растений. Их листья ловят солнечные лучи с помощью пигмента хлорофилла, корни всасывают воду из земли, а поры впитывают углекислый газ из воздуха. '
            'Соединяя все это вместе с энергией солнца, растение создает себе питательную глюкозу для роста и выделяет в воздух кислород, которым дышим мы!',
        summary:
            'Растения превращают солнечный свет, воду и углекислый газ в питательный сахар и чистый кислород.',
        stepByStepGuide: [
          'Шаг 1: Зеленый хлорофилл в листьях улавливает лучи солнца.',
          'Шаг 2: Корни подают воду, а листья вдыхают углекислый газ из воздуха.',
          'Шаг 3: Энергия солнца запускает реакцию: получается глюкоза (питание) и выделяется кислород.',
        ],
        keyConcepts: [
          KeyConceptModel(
            term: 'Хлорофилл',
            definition: 'Зеленая «солнечная батарейка» внутри листа, улавливающая свет.',
          ),
          KeyConceptModel(
            term: 'Глюкоза',
            definition: 'Природный сахар, главный источник энергии и строитель клеток растения.',
          ),
          KeyConceptModel(
            term: 'Кислород',
            definition: 'Полезный газ, который выделяют растения при фотосинтезе для нашего дыхания.',
          ),
        ],
        practicalExamples: [
          'Наглядный пример: это работает как солнечные батареи на крыше умного дома, которые вырабатывают чистую энергию из света.',
        ],
        videoTitle: 'Обучающий мультфильм: Как работает фотосинтез?',
        videoUrl:
            'https://www.youtube.com/results?search_query=%D1%84%D0%BE%D1%82%D0%BE%D1%81%D0%B8%D0%BD%D1%82%D0%B5%D0%B7+%D0%B0%D0%BD%D0%B8%D0%BC%D0%B0%D1%86%D0%B8%D1%8F+%D0%B4%D0%B5%D1%82%D1%8F%D0%BC',
      );
    }

    // 3. Теорема Пифагора
    if (lower.contains('пифагор') || lower.contains('треугольник')) {
      return SimplifiedResultModel(
        title: 'Теорема Пифагора: квадрат гипотенузы',
        simpleExplanation:
            'В любом прямоугольном треугольнике (где один угол прямой, как угол тетради) площадь квадрата на самой длинной стороне в точности равна сумме площадей двух квадратов на коротких сторонах: a² + b² = c².',
        summary:
            'Сумма квадратов катетов всегда равна квадрату гипотенузы (a² + b² = c²).',
        stepByStepGuide: [
          'Шаг 1: Найдите прямой угол (90 градусов).',
          'Шаг 2: Возведите две короткие стороны (катеты) в квадрат и сложите их.',
          'Шаг 3: Извлеките квадратный корень из суммы — это длина длинной стороны.',
        ],
        keyConcepts: [
          KeyConceptModel(
            term: 'Гипотенуза',
            definition: 'Самая длинная сторона треугольника, лежащая напротив прямого угла.',
          ),
          KeyConceptModel(
            term: 'Катеты',
            definition: 'Две стороны, образующие между собой прямой угол.',
          ),
        ],
        practicalExamples: [
          'Пример: если прислонить лестницу к стене на расстоянии 3 метра при высоте 4 метра, длина лестницы будет ровно 5 метров (3² + 4² = 9 + 16 = 25 = 5²).',
        ],
        videoTitle: 'Анимация: Наглядное доказательство теоремы Пифагора с водой',
        videoUrl:
            'https://www.youtube.com/results?search_query=%D1%82%D0%B5%D0%BE%D1%80%D0%B5%D0%BC%D0%B0+%D0%BF%D0%B8%D1%84%D0%B0%D0%B3%D0%BE%D1%80%D0%B0+%D0%BD%D0%B0%D0%B3%D0%BB%D1%8F%D0%B4%D0%BD%D0%BE+%D0%B0%D0%BD%D0%B8%D0%BC%D0%B0%D1%86%D0%B8%D1%8F',
      );
    }

    // 4. Гравитация
    if (lower.contains('гравитац') || lower.contains('притяжен') || lower.contains('ньютон')) {
      return SimplifiedResultModel(
        title: 'Гравитация: невидимый магнит Вселенной',
        simpleExplanation:
            'Гравитация — это невидимая сила притяжения между любыми телами, имеющими массу. '
            'Наша планета Земля огромная и тяжелая, поэтому она притягивает к себе всё: нас, дома, машины и даже Луну на орбите! '
            'Благодаря гравитации мы не улетаем в открытый космос, а реки текут вниз.',
        summary:
            'Гравитация притягивает предметы друг к другу: чем массивнее объект, тем сильнее его притяжение.',
        stepByStepGuide: [
          'Шаг 1: Любой предмет с массой притягивает к себе другие предметы.',
          'Шаг 2: Земля очень тяжелая, поэтому ее притяжение чувствуется сильнее всего.',
          'Шаг 3: Гравитация удерживает атмосферу, океаны и Луну на ее орбите.',
        ],
        keyConcepts: [
          KeyConceptModel(
            term: 'Гравитация',
            definition: 'Сила всемирного тяготения, притягивающая тела друг к другу.',
          ),
          KeyConceptModel(
            term: 'Масса',
            definition: 'Количество вещества в предмете: чем больше масса, тем сильнее гравитация.',
          ),
        ],
        practicalExamples: [
          'Жизненный пример: когда ты подпрыгиваешь, гравитация Земли плавно и надежно возвращает тебя обратно на пол!',
        ],
        videoTitle: 'Обучающий мультфильм: Что такое гравитация простыми словами?',
        videoUrl:
            'https://www.youtube.com/results?search_query=%D0%B3%D1%80%D0%B0%D0%B2%D0%B8%D1%82%D0%B0%D1%86%D0%B8%D1%8F+%D0%B4%D0%B5%D1%82%D1%8F%D0%BC+%D0%B0%D0%BD%D0%B8%D0%BC%D0%B0%D1%86%D0%B8%D1%8F',
      );
    }

    // 5. Dynamic Topic Fallback for any other user-entered topic
    final cleanTopic = text.trim().length <= 40 ? text.trim() : 'Изучаемый материал';
    return SimplifiedResultModel(
      title: '$cleanTopic: простое и понятное объяснение',
      simpleExplanation:
          'Давай разберем тему "$cleanTopic" простыми словами без заумных терминов. '
          'Каждое сложное явление в природе или науке устроено очень логично: оно состоит из понятных базовых шагов. '
          'Когда мы раскладываем его на наглядные примеры из жизни, всё сразу встает на свои места!',
      summary:
          'Тема "$cleanTopic" объяснена простыми жизненными аналогиями с пошаговым разбором.',
      stepByStepGuide: [
        'Шаг 1: Выделите главную мысль темы "$cleanTopic".',
        'Шаг 2: Рассмотрите, как это правило проявляется на конкретных примерах.',
        'Шаг 3: Закрепите понимание с помощью видеоролика и жизненной практики.',
      ],
      keyConcepts: [
        KeyConceptModel(
          term: cleanTopic,
          definition: 'Ключевая идея изучаемой темы, сформулированная простым языком.',
        ),
        KeyConceptModel(
          term: 'Практический эффект',
          definition: 'То, как данный закон или принцип работает в реальной жизни.',
        ),
      ],
      practicalExamples: [
        'Пример из жизни: представь механизм часов — каждая деталь слаженно выполняет свою роль, приводя в движение весь механизм.',
      ],
      videoTitle: 'Обучающий видеоурок: $cleanTopic (Анимация)',
      videoUrl:
          'https://www.youtube.com/results?search_query=${Uri.encodeComponent('$cleanTopic детям понятно анимация')}',
    );
  }

  Future<List<Map<String, dynamic>>> getSavedMaterials() async {
    try {
      final res = await _apiClient.dio.get('/inclusive/materials');
      return (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return _getLocalMaterials();
    }
  }

  void _saveLocalMaterial(String originalText, SimplifiedResultModel result) {
    final list = _getLocalMaterials();
    list.insert(0, {
      'id': 'mat-${DateTime.now().millisecondsSinceEpoch}',
      'original': originalText,
      'title': result.title,
      'summary': result.summary,
      'simplified': result.toMap(),
      'created_at': DateTime.now().toIso8601String(),
    });
    _prefs.setString(_materialsKey, json.encode(list));
  }

  List<Map<String, dynamic>> _getLocalMaterials() {
    final raw = _prefs.getString(_materialsKey);
    if (raw == null) return [];
    try {
      final decoded = json.decode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
