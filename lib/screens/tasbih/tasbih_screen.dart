// اسم الملف: lib/screens/tasbih/tasbih_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _sessionCount = 0;
  int _totalCount = 0;
  static const String _totalCountKey = 'total_tasbih_count';

  @override
  void initState() {
    super.initState();
    _loadTotalCount();
  }

  // تحميل المجموع الكلي من الذاكرة
  Future<void> _loadTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalCount = prefs.getInt(_totalCountKey) ?? 0;
    });
  }

  // حفظ المجموع الكلي في الذاكرة
  Future<void> _saveTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalCountKey, _totalCount);
  }

  // زيادة العداد
  void _increment() async {
    setState(() {
      _sessionCount++;
      _totalCount++;
    });
    _saveTotalCount();
    
    // إضافة اهتزاز عند الضغط
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }
  }

  // إعادة تعيين عداد الجلسة الحالية
  void _resetSession() {
    setState(() {
      _sessionCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardTheme.color ?? const Color(0xFFF5F5DC);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المسبحة الإلكترونية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // عرض المجموع الكلي
            _buildTotalCountCard(primaryColor, cardColor),
            
            // العداد الرئيسي
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _increment,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 15,
                        ),
                      ],
                      border: Border.all(color: primaryColor, width: 4),
                    ),
                    child: Center(
                      child: Text(
                        _sessionCount.toString(),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // زر إعادة التعيين
            IconButton(
              onPressed: _resetSession,
              icon: const Icon(Icons.refresh),
              iconSize: 35,
              color: primaryColor.withOpacity(0.8),
              tooltip: 'إعادة تعيين العداد الحالي',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCountCard(Color primaryColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            'المجموع الكلي للتسبيحات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _totalCount.toString(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
