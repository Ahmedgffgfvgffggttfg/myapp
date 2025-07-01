// اسم الملف: lib/models/azkar_model.dart

class Zekr {
  final String category;
  final String count;
  final String description;
  final String reference;
  final String zekr;

  Zekr({
    required this.category,
    required this.count,
    required this.description,
    required this.reference,
    required this.zekr,
  });

  // دالة لإنشاء كائن Zekr من بيانات JSON (Map)
  factory Zekr.fromJson(Map<String, dynamic> json) {
    return Zekr(
      category: json['category'] as String? ??
          '', // التعامل مع القيم الفارغة المحتملة
      count: json['count'] as String? ?? '',
      description: json['description'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      zekr: json['zekr'] as String? ?? '',
    );
  }
}
