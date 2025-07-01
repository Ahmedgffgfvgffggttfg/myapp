import 'dart:convert';

List<Question> questionFromJson(String str) =>
    List<Question>.from(json.decode(str).map((x) => Question.fromJson(x)));

String questionToJson(List<Question> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Question {
  final int id;
  final String question;
  final List<Option> options;
  final String difficulty;
  final String category;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.difficulty,
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json["id"],
        question: json["question"],
        options:
            List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
        difficulty: json["difficulty"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "options": List<dynamic>.from(options.map((x) => x.toJson())),
        "difficulty": difficulty,
        "category": category,
      };
}

class Option {
  final String text;
  final bool isCorrect;

  Option({
    required this.text,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        text: json["text"],
        isCorrect: json["isCorrect"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "isCorrect": isCorrect,
      };
}
