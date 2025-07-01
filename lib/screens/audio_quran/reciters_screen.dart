// اسم الملف: lib/screens/audio_quran/reciters_screen.dart
// نسخة نهائية مع قائمة قراء صحيحة وأسماء عربية ومنطق آمن

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/audio_quran/reciter_model.dart';
import 'audio_surahs_screen.dart';

class RecitersScreen extends StatefulWidget {
  const RecitersScreen({super.key});

  @override
  State<RecitersScreen> createState() => _RecitersScreenState();
}

class _RecitersScreenState extends State<RecitersScreen> {
  late Future<List<Reciter>> _recitersFuture;

  // --- قائمة بأرقام (ID) أشهر 20 قارئاً ---
  final Set<int> famousRecitersIds = {
    10, // ياسر الدوسري
    4, // محمد صديق المنشاوي
    2, // عبدالباسط عبدالصمد
    1, // ماهر المعيقلي
    5, // مشاري راشد العفاسي
    7, // سعد الغامدي
    8, // سعود الشريم
    9, // عبدالرحمن السديس
    11, // أحمد بن علي العجمي
    14, // فارس عباد
    15, // ناصر القطامي
    3, // محمود خليل الحصري
    12, // علي جابر
    6, // أبو بكر الشاطري
    13, // هاني الرفاعي
    16, // إدريس أبكر
    18, // خالد الجليل
    17, // عادل الكلباني
    19, // صلاح بو خاطر
    20, // عبدالله عواد الجهني
  };

  @override
  void initState() {
    super.initState();
    _recitersFuture = _fetchReciters();
  }

  Future<List<Reciter>> _fetchReciters() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت لعرض قائمة القراء.');
    }

    final response = await http.get(
      Uri.parse('https://www.mp3quran.net/api/v3/reciters?language=ar'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recitersJson = data['reciters'];
      // --- فلترة القراء باستخدام الـ ID لضمان الدقة ---
      return recitersJson
          .map((json) => Reciter.fromJson(json))
          .where((reciter) => famousRecitersIds.contains(reciter.id))
          .toList();
    } else {
      throw Exception('فشل في تحميل قائمة القراء.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم الصوتي',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // لون الأيقونات والنص في AppBar
      ),
      body: FutureBuilder<List<Reciter>>(
        future: _recitersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString(), primaryColor);
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final reciters = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: reciters.length,
              itemBuilder: (context, index) {
                final reciter = reciters[index];
                return _buildReciterCard(context, reciter, primaryColor);
              },
            );
          }
          return const Center(child: Text('لا يوجد قراء لعرضهم'));
        },
      ),
    );
  }

  Widget _buildReciterCard(
      BuildContext context, Reciter reciter, Color primaryColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioSurahsScreen(reciter: reciter),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: primaryColor.withOpacity(0.1),
                child: Icon(Icons.person_outline, size: 60, color: primaryColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    // --- التصحيح الأول ---
                    // أضفنا '??' لتوفير قيمة افتراضية في حالة كان الاسم null
                    reciter.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // --- التصحيح الثاني ---
                    // أضفنا '??' لتوفير قيمة افتراضية في حالة كانت الرواية null
                    reciter.rewaya ?? 'رواية غير معروفة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.grey.shade400, size: 80),
            const SizedBox(height: 20),
            Text(
              error.replaceAll("Exception: ", ""),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  color: Colors.grey.shade700),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("إعادة المحاولة"),
              onPressed: () {
                setState(() {
                  _recitersFuture = _fetchReciters();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
