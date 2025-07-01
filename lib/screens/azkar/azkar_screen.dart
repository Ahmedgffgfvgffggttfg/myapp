// اسم الملف: lib/screens/azkar/azkar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../../models/azkar_model.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  Map<String, List<Zekr>> _categorizedAzkar = {};
  bool _isLoading = true;
  String? _errorLoading;

  @override
  void initState() {
    super.initState();
    _loadAzkarData();
  }

  Future<void> _loadAzkarData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorLoading = null;
    });
    try {
      // 1. تحميل ملف JSON من مجلد الأصول
      final String response =
          await rootBundle.loadString('assets/azkar_data.json');
      // 2. تحويل النص إلى قائمة من الفئات
      final List<dynamic> categoriesJson =
          json.decode(response) as List<dynamic>;

      final List<Zekr> loadedAzkar = [];
      // 3. المرور على كل فئة في القائمة
      for (var categoryData in categoriesJson) {
        // استخراج اسم الفئة
        String categoryName = categoryData['category'];
        // استخراج قائمة الأذكار الداخلية (array)
        List<dynamic> zekrArray = categoryData['array'];

        // 4. المرور على كل ذكر داخل الفئة الحالية
        for (var zekrData in zekrArray) {
          // 5. إنشاء كائن Zekr جديد بالبيانات الصحيحة
          final zekrObject = Zekr(
            category: categoryName, // استخدام اسم الفئة من الحلقة الخارجية
            zekr: zekrData['text'] ?? '', // استخدام 'text' بدلاً من 'zekr'
            count: zekrData['count']?.toString() ?? '1', // تحويل الرقم إلى نص
            description: zekrData['description'] ?? '', // قيمة افتراضية
            reference: zekrData['reference'] ?? '', // قيمة افتراضية
          );
          loadedAzkar.add(zekrObject);
        }
      }

      // 6. تجميع الأذكار في الخريطة النهائية للعرض
      Map<String, List<Zekr>> categorized = {};
      for (var zekrItem in loadedAzkar) {
        categorized.putIfAbsent(zekrItem.category, () => []).add(zekrItem);
      }

      if (mounted) {
        setState(() {
          _categorizedAzkar = categorized;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print("Error loading Azkar data: $e");
      print("Stack trace: $stackTrace");
      if (mounted) {
        setState(() {
          _errorLoading = "حدث خطأ أثناء تحميل الأذكار.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle defaultTextStyle = TextStyle(
        fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily ?? 'Cairo');
    TextStyle pageTitleStyle = defaultTextStyle.copyWith(
      color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.white,
      fontWeight: Theme.of(context).appBarTheme.titleTextStyle?.fontWeight ??
          FontWeight.bold,
      fontSize:
          Theme.of(context).appBarTheme.titleTextStyle?.fontSize ?? 20,
    );
    TextStyle categoryTitleStyle = defaultTextStyle.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColor,
    );
    TextStyle zekrTextStyle = defaultTextStyle.copyWith(
        fontSize: 16,
        height: 1.6,
        color: Theme.of(context).textTheme.bodyLarge?.color);
    TextStyle descriptionTextStyle = defaultTextStyle.copyWith(
        fontSize: 13,
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
        height: 1.4);
    TextStyle countTextStyle = defaultTextStyle.copyWith(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w600); // لون النص أبيض للـ Chip

    return Scaffold(
      appBar: AppBar(
        title: Text('الأذكار', style: pageTitleStyle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorLoading != null
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_errorLoading!,
                      style: defaultTextStyle.copyWith(
                          color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center),
                ))
              : _categorizedAzkar.isEmpty
                  ? Center(
                      child: Text(
                      "لا توجد أذكار لعرضها أو لم يتم تحميلها بشكل صحيح.",
                      style: defaultTextStyle.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: _categorizedAzkar.keys.length,
                      itemBuilder: (context, index) {
                        String category =
                            _categorizedAzkar.keys.elementAt(index);
                        List<Zekr> azkarInCategory =
                            _categorizedAzkar[category]!;

                        if (azkarInCategory.isEmpty) {
                          // إذا كانت الفئة فارغة لسبب ما
                          return const SizedBox.shrink(); // لا تعرض شيئًا
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            key: PageStorageKey<String>(category),
                            title: Text(category, style: categoryTitleStyle),
                            iconColor: Theme.of(context).primaryColor,
                            collapsedIconColor:
                                Theme.of(context).primaryColor.withOpacity(0.7),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0), // تقليل الحشو العلوي
                            children: azkarInCategory.map((zekrItem) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0,
                                    bottom:
                                        8.0), // تعديل الحشو الداخلي لكل ذكر
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(zekrItem.zekr,
                                        style: zekrTextStyle,
                                        textAlign: TextAlign.right),
                                    if (zekrItem.description.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(zekrItem.description,
                                          style: descriptionTextStyle,
                                          textAlign: TextAlign.right),
                                    ],
                                    if (zekrItem.count.isNotEmpty &&
                                        zekrItem.count != "0") ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: AlignmentDirectional
                                            .centerStart, // ليدعم RTL بشكل أفضل
                                        child: Chip(
                                          label: Text(
                                              "التكرار: ${zekrItem.count}",
                                              style: countTextStyle),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.8),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 3.0), // تعديل الحشو للـ Chip
                                        ),
                                      ),
                                    ],
                                    if (zekrItem.reference.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: Text(
                                            "المرجع: ${zekrItem.reference}",
                                            style: descriptionTextStyle
                                                .copyWith(fontSize: 11)),
                                      ),
                                    ],
                                    if (azkarInCategory.last != zekrItem)
                                      const Divider(
                                          height: 25,
                                          thickness: 0.5,
                                          indent: 10,
                                          endIndent: 10),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
    );
  }
}
