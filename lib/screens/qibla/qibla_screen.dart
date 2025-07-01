// اسم الملف: lib/screens/qibla/qibla_screen.dart
// نسخة نهائية بتصميم وألوان متناسقة مع هوية التطبيق

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
// ignore: unused_import
import 'package:app_settings/app_settings.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _heading = 0.0;
  double? _qiblaDirection;
  
  Animation<double>? _animation;
  AnimationController? _animationController;

  final double _kaabaLatitude = 21.4225;
  final double _kaabaLongitude = 39.8262;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween(begin: 0.0, end: 0.0).animate(_animationController!);
    _initLocationAndCompass();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndCompass() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _errorMessage = "يرجى تفعيل خدمات الموقع (GPS) لتحديد اتجاه القبلة.";
          _isLoading = false;
        });
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
       if (mounted) {
        setState(() {
          _errorMessage = "تم رفض إذن الموقع. لا يمكن تحديد القبلة بدون هذا الإذن.";
          _isLoading = false;
        });
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      
      _calculateQiblaDirection(position);

      _compassSubscription = FlutterCompass.events!.listen((CompassEvent event) {
        if (!mounted || event.heading == null) return;
        
        double newHeading = event.heading!;
        double oldRad = (_heading) * (math.pi / 180);
        double newRad = newHeading * (math.pi / 180);
        
        if ((newRad - oldRad).abs() > math.pi) {
            if (newRad > oldRad) {
                oldRad += 2 * math.pi;
            } else {
                newRad += 2 * math.pi;
            }
        }
        
        _animation = Tween(begin: oldRad, end: newRad).animate(_animationController!);
        _animationController!.forward(from: 0);

        setState(() {
          _heading = newHeading;
        });
      });

      if (mounted) setState(() => _isLoading = false);

    } on TimeoutException {
        if (mounted) {
          setState(() {
          _errorMessage = "لا يمكن التقاط إشارة GPS. يرجى المحاولة في مكان مفتوح.";
          _isLoading = false;
        });
        }
    } catch (e) {
      if (mounted) {
        setState(() {
        _errorMessage = "حدث خطأ غير متوقع أثناء تحديد الموقع.";
        _isLoading = false;
      });
      }
    }
  }

  void _calculateQiblaDirection(Position position) {
    final double userLat = position.latitude * (math.pi / 180.0);
    final double userLon = position.longitude * (math.pi / 180.0);
    final double latKaaba = _kaabaLatitude * (math.pi / 180.0);
    final double lonKaaba = _kaabaLongitude * (math.pi / 180.0);
    final double lonDiff = lonKaaba - userLon;

    final double y = math.sin(lonDiff) * math.cos(latKaaba);
    final double x = math.cos(userLat) * math.sin(latKaaba) -
        math.sin(userLat) * math.cos(latKaaba) * math.cos(lonDiff);
    
    final double direction = (math.atan2(y, x) * (180.0 / math.pi));

    setState(() => _qiblaDirection = (direction + 360) % 360);
  }

  @override
  Widget build(BuildContext context) {
    // استخدام ألوان الثيم الرئيسي
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // أيقونات شريط الحالة داكنة لتناسب الخلفية البيضاء
      child: Scaffold(
        backgroundColor: scaffoldColor, // خلفية بيضاء
        appBar: AppBar(
          title: const Text('اتجاه القبلة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          backgroundColor: primaryColor, // لون زيتوني
          elevation: 1,
        ),
        body: SafeArea(
          child: Center(
            child: _isLoading
                ? CircularProgressIndicator(color: primaryColor)
                : _errorMessage != null
                    ? _buildErrorView()
                    : _buildCompassView(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded, color: Colors.red.shade700, size: 80),
          const SizedBox(height: 20),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Colors.grey.shade800, height: 1.5),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("إعادة المحاولة", style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: _initLocationAndCompass,
          ),
        ],
      ),
    );
  }

  Widget _buildCompassView() {
    if (_qiblaDirection == null) {
      return Center(child: Text("جاري حساب اتجاه القبلة...", style: TextStyle(color: Colors.grey.shade700, fontFamily: 'Cairo')));
    }
    
    final bool isAligned = (_qiblaDirection! - _heading).abs() < 5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text("اتجاه القبلة", style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade600, fontSize: 20)),
            Text("${_qiblaDirection!.toStringAsFixed(1)}°", style: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).primaryColor, fontSize: 48, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(
          width: 300,
          height: 300,
          child: AnimatedBuilder(
            animation: _animationController!,
            builder: (context, child) {
              final rotationAngle = _animation!.value;
              return Transform.rotate(
                angle: -rotationAngle,
                child: CustomPaint(
                  painter: CompassPainter(
                    qiblaDirection: _qiblaDirection! * (math.pi / 180),
                    isAligned: isAligned,
                    primaryColor: Theme.of(context).primaryColor,
                    accentColor: Theme.of(context).cardTheme.color ?? const Color(0xFFF5F5DC),
                  ),
                ),
              );
            },
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: isAligned ? Theme.of(context).primaryColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            isAligned ? "أنت في الاتجاه الصحيح" : "قم بتدوير الجهاز",
            style: TextStyle(
              fontFamily: 'Cairo', 
              fontSize: 18, 
              color: isAligned ? Colors.white : Colors.black87, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }
}

// --- رسام البوصلة المخصص بالألوان الجديدة ---
class CompassPainter extends CustomPainter {
  final double qiblaDirection;
  final bool isAligned;
  final Color primaryColor;
  final Color accentColor;

  CompassPainter({
    required this.qiblaDirection, 
    required this.isAligned,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // --- رسم الخلفية والحدود ---
    final backgroundPaint = Paint()
      ..color = accentColor // لون البيج
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    final borderPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, borderPaint);

    // --- رسم مؤشرات الدرجات ---
    final tickPaint = Paint()..color = primaryColor.withOpacity(0.7);
    for (int i = 0; i < 360; i += 15) {
      final isMajorTick = i % 90 == 0;
      tickPaint.strokeWidth = isMajorTick ? 2.5 : 1.5;
      final tickLength = isMajorTick ? 15.0 : 8.0;
      
      final angle = i * (math.pi / 180);
      final p1 = center + Offset(math.sin(angle), -math.cos(angle)) * (radius - 5);
      final p2 = center + Offset(math.sin(angle), -math.cos(angle)) * (radius - 5 - tickLength);
      canvas.drawLine(p1, p2, tickPaint);
    }

    // --- رسم إبرة القبلة ---
    final qiblaPaint = Paint()
      ..color = isAligned ? const Color(0xFF27AE60) : primaryColor // لون زيتوني
      ..style = PaintingStyle.fill;

    final qiblaPath = Path();
    qiblaPath.moveTo(center.dx, center.dy - radius + 15);
    qiblaPath.lineTo(center.dx - 15, center.dy);
    qiblaPath.lineTo(center.dx + 15, center.dy);
    qiblaPath.close();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(qiblaDirection);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(qiblaPath, qiblaPaint);
    canvas.restore();

    // --- رسم المؤشر العلوي (يشير لاتجاه الهاتف) ---
    final topIndicatorPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    final topPath = Path();
    topPath.moveTo(center.dx, center.dy - radius - 10);
    topPath.lineTo(center.dx - 10, center.dy - radius + 5);
    topPath.lineTo(center.dx + 10, center.dy - radius + 5);
    topPath.close();
    canvas.drawPath(topPath, topIndicatorPaint);

    // --- رسم دائرة المركز ---
    final centerCirclePaint = Paint()..color = primaryColor;
    canvas.drawCircle(center, 6, centerCirclePaint);
    final innerCenterCirclePaint = Paint()..color = accentColor;
    canvas.drawCircle(center, 3, innerCenterCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
