import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'question_model.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  Timer? _timer;
  int _timerSeconds = 20;
  bool _answered = false;
  Option? _selectedOption;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String response =
        await rootBundle.loadString('assets/Questions_competition.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _questions = data.map((json) => Question.fromJson(json)).toList();
      _questions.shuffle();
    });
    _startTimer();
  }

  void _startTimer() {
    _timerSeconds = (20 + (_currentIndex * 2)).clamp(20, 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
        _restartGameWithMessage('الوقت انتهى! حاول مرة أخرى.');
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  void _nextQuestion() {
    _timer?.cancel();
    setState(() {
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _answered = false;
        _selectedOption = null;
        _startTimer();
      } else {
        _showSuccessDialog();
      }
    });
  }

  void _restartGame() {
    _timer?.cancel();
    setState(() {
      _currentIndex = 0;
      _answered = false;
      _selectedOption = null;
      _questions.shuffle();
    });
    _startTimer();
  }

  void _restartGameWithMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), _restartGame);
  }

  void _checkAnswer(Option option) {
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedOption = option;
    });

    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (option.isCorrect) {
        _nextQuestion();
      } else {
        _restartGameWithMessage('إجابة خاطئة! حاول مرة أخرى.');
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'عمل جيد!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F)),
          ),
          content: const Text(
            'لقد أكملت جميع الأسئلة بنجاح. أنت رائع!',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('العب مرة أخرى',
                  style: TextStyle(color: Color(0xFF556B2F))),
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('لعبة الأسئلة'),
        ),
        backgroundColor: Colors.white,
        body: const Center(
            child: CircularProgressIndicator(color: Color(0xFF556B2F))),
      );
    }

    final Question currentQuestion = _questions[_currentIndex];
    final double progress = (_currentIndex + 1) / _questions.length;
    final int maxTime = (20 + (_currentIndex * 2)).clamp(20, 60);
    const Color primaryColor = Color(0xFF556B2F);
    const Color secondaryColor = Color(0xFFF5F5DC);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('لعبة الأسئلة'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuestionProgress(progress, primaryColor),
                  const SizedBox(width: 20),
                  _buildTimer(maxTime, primaryColor),
                ],
              ),
              const SizedBox(height: 20),
              _buildQuestionCard(currentQuestion, secondaryColor),
              const SizedBox(height: 25),
              ...currentQuestion.options
                  .map((option) => _buildOption(option, primaryColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionProgress(double progress, Color textColor) {
    return SizedBox(
      width: 85,
      height: 85,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(Colors.blue, Colors.red, progress) ?? Colors.blue,
            ),
          ),
          Center(
            child: Text(
              '${_currentIndex + 1}',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(int maxTime, Color primaryColor) {
    return SizedBox(
      width: 85,
      height: 85,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
                begin: _timerSeconds / maxTime, end: _timerSeconds / maxTime),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            builder: (context, value, child) => CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.lerp(Colors.red, primaryColor, _timerSeconds / 20) ??
                    primaryColor,
              ),
            ),
          ),
          Center(
            child: Text(
              '$_timerSeconds',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question currentQuestion, Color cardColor) {
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'السؤال ${_currentIndex + 1} من ${_questions.length}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currentQuestion.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Uthmani',
                fontSize: 23,
                fontWeight: FontWeight.bold,
                height: 1.5,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(Option option, Color primaryColor) {
    Color getOptionColor() {
      if (!_answered) return Colors.white;
      if (option.isCorrect) return Colors.green.shade50;
      if (option == _selectedOption && !option.isCorrect) {
        return Colors.red.shade50;
      }
      return Colors.white;
    }

    Border getOptionBorder() {
      if (!_answered) return Border.all(color: Colors.grey.shade300);
      if (option.isCorrect) return Border.all(color: primaryColor, width: 2);
      if (option == _selectedOption && !option.isCorrect) {
        return Border.all(color: Colors.red, width: 2);
      }
      return Border.all(color: Colors.grey.shade300);
    }

    Icon? getOptionIcon() {
      if (!_answered) return null;
      if (option.isCorrect) {
        return Icon(Icons.check_circle, color: primaryColor);
      }
      if (option == _selectedOption && !option.isCorrect) {
        return const Icon(Icons.cancel, color: Colors.red);
      }
      return null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: InkWell(
        onTap: _answered ? null : () => _checkAnswer(option),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: getOptionColor(),
            border: getOptionBorder(),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  option.text,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (getOptionIcon() != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: getOptionIcon(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
