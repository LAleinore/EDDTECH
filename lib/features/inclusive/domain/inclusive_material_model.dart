class KeyConceptModel {
  final String term;
  final String definition;

  KeyConceptModel({required this.term, required this.definition});

  factory KeyConceptModel.fromMap(Map<String, dynamic> map) {
    return KeyConceptModel(
      term: map['term'] ?? '',
      definition: map['definition'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'term': term, 'definition': definition};
}

class SimplifiedResultModel {
  final String title;
  final String simpleExplanation;
  final String summary;
  final List<String> stepByStepGuide;
  final List<KeyConceptModel> keyConcepts;
  final List<String> practicalExamples;

  SimplifiedResultModel({
    required this.title,
    required this.simpleExplanation,
    required this.summary,
    required this.stepByStepGuide,
    required this.keyConcepts,
    required this.practicalExamples,
  });

  factory SimplifiedResultModel.fromMap(Map<String, dynamic> map) {
    return SimplifiedResultModel(
      title: map['title'] ?? 'Адаптированный материал',
      simpleExplanation:
          map['simpleExplanation'] ?? map['simple_explanation'] ?? '',
      summary: map['summary'] ?? '',
      stepByStepGuide: List<String>.from(
        map['stepByStepGuide'] ?? map['step_by_step_guide'] ?? [],
      ),
      keyConcepts:
          (map['keyConcepts'] as List? ?? map['key_concepts'] as List? ?? [])
              .map((k) => KeyConceptModel.fromMap(Map<String, dynamic>.from(k)))
              .toList(),
      practicalExamples: List<String>.from(
        map['practicalExamples'] ?? map['practical_examples'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'simpleExplanation': simpleExplanation,
    'summary': summary,
    'stepByStepGuide': stepByStepGuide,
    'keyConcepts': keyConcepts.map((k) => k.toMap()).toList(),
    'practicalExamples': practicalExamples,
  };
}
