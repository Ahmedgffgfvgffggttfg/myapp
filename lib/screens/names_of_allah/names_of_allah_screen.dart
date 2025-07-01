// اسم الملف: lib/screens/names_of_allah/names_of_allah_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/name_of_allah_model.dart';
import 'name_details_screen.dart';

class NamesOfAllahScreen extends StatefulWidget {
  const NamesOfAllahScreen({super.key});

  @override
  _NamesOfAllahScreenState createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen> {
  late Future<List<NameOfAllah>> _namesOfAllah;

  @override
  void initState() {
    super.initState();
    _namesOfAllah = _loadNamesOfAllah();
  }

  Future<List<NameOfAllah>> _loadNamesOfAllah() async {
    String data = await rootBundle.loadString('assets/Names_Of_Allah.json');
    List<dynamic> jsonResult = json.decode(data);
    return jsonResult.map((json) => NameOfAllah.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle pageTitleStyle = TextStyle(
      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily ?? 'Cairo',
      color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.white,
      fontWeight: Theme.of(context).appBarTheme.titleTextStyle?.fontWeight ?? FontWeight.bold,
      fontSize: Theme.of(context).appBarTheme.titleTextStyle?.fontSize ?? 20,
    );

    TextStyle listItemStyle = TextStyle(
        fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily ?? 'Cairo',
        fontSize: 22,
        fontWeight: FontWeight.bold
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('أسماء الله الحسنى', style: pageTitleStyle),
      ),
      body: FutureBuilder<List<NameOfAllah>>(
        future: _namesOfAllah,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد بيانات'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final nameOfAllah = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(nameOfAllah.name, style: listItemStyle),
                    leading: CircleAvatar(
                      child: Text(
                        '${nameOfAllah.id}',
                        style: listItemStyle.copyWith(fontSize: 16),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NameDetailsScreen(nameOfAllah: nameOfAllah),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
