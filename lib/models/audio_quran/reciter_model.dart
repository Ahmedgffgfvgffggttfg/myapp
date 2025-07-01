// اسم الملف: lib/models/audio_quran/reciter_model.dart

class Reciter {
  final int id;
  final String name;
  final String relativePath; // المسار النسبي للقارئ

  Reciter({
    required this.id,
    required this.name,
    required this.relativePath,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'غير معروف',
      relativePath: json['relative_path'] ?? '',
    );
  }

  get serverUrl => null;

  String? get rewaya => null;
}

