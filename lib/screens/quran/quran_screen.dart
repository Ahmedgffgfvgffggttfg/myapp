// اسم الملف: lib/screens/quran/quran_screen.dart
// نسخة محسنة مع مسارات صحيحة ومنطق سليم

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/quran/surah_model.dart'; // <-- المسار الصحيح للملف
import 'surah_detail_screen.dart';
import 'package:flutter/foundation.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late Future<List<Surah>> _surahsFuture;

  @override
  void initState() {
    super.initState();
    _surahsFuture = _loadQuranData();
  }

  Future<List<Surah>> _loadQuranData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/quran.json');
      // استخدام compute لفك التشفير في الخلفية ومنع تجميد الواجهة
      return await compute(parseSurahs, jsonString);
    } catch (e) {
      // التعامل مع أي خطأ قد يحدث أثناء تحميل الملف
      throw Exception('فشل تحميل بيانات القرآن. تأكد من وجود ملف quran.json في مجلد assets.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
      ),
      body: FutureBuilder<List<Surah>>(
        future: _surahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString(), primaryColor);
          }
          if (snapshot.hasData) {
            final surahs = snapshot.data!;
            return ListView.separated(
              itemCount: surahs.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: primaryColor.withOpacity(0.1),
                indent: 70,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final surah = surahs[index];
                return _buildSurahTile(context, surah, primaryColor);
              },
            );
          }
          return const Center(child: Text('لا توجد بيانات لعرضها'));
        },
      ),
    );
  }

  Widget _buildSurahTile(BuildContext context, Surah surah, Color primaryColor) {
    return ListTile(
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            // --- عرض رقم السورة الصحيح ---
            surah.number.toString(),
            style: TextStyle(
              fontFamily: 'Cairo',
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      title: Text(
        surah.name,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        '${surah.type == 'Makkiyah' ? 'مكية' : 'مدنية'} - ${surah.totalVerses} آيات',
        style: TextStyle(
          fontFamily: 'Cairo',
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: primaryColor.withOpacity(0.5)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailScreen(surah: surah),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(String error, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 60),
            const SizedBox(height: 20),
            Text(
              error.replaceAll("Exception: ", ""),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo', 
                fontSize: 18, 
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

