import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:renkli_zeka_ar_macera/services/stats_service.dart';

// Oyun için kullanılacak nesneler ve emoji karşılıkları
const Map<String, String> gameAssets = {
  'elma': '🍎',
  'armut': '🍐',
  'muz': '🍌',
  'çilek': '🍓',
  'karpuz': '🍉',
  'kedi': '🐈',
  'köpek': '🐕',
  'kuş': '🐦',
  'tavşan': '🐇',
  'aslan': '🦁',
};

// Motivasyonel sesli mesajlar
const List<String> correctMessages = ['Harikasın!', 'Süpersin!', 'Çok doğru!', 'Bravo!'];
const List<String> incorrectMessages = ['Tekrar deneyelim.', 'Neredeyse doğru.', 'Bir daha düşünelim mi?'];


class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;

  // Rastgele oluşturulmuş sorular
  final List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _setupTts();
    _generateQuestions();
    // İlk soruyu gecikmeli olarak sor
    Future.delayed(const Duration(milliseconds: 500), () => _speakQuestion());
  }
  
  void _setupTts() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(1.2); // Daha yumuşak bir kadın sesi için
  }

  void _generateQuestions() {
    final random = Random();
    final assetKeys = gameAssets.keys.toList();

    for (int i = 0; i < 10; i++) {
      int num1 = random.nextInt(5) + 1;
      int num2 = random.nextInt(5) + 1;
      bool isAddition = random.nextBool();

      // Çıkarma işlemi için num1'in büyük olmasını sağla
      if (!isAddition && num1 < num2) {
        int temp = num1;
        num1 = num2;
        num2 = temp;
      }

      int correctAnswer = isAddition ? num1 + num2 : num1 - num2;
      String op1Asset = assetKeys[random.nextInt(assetKeys.length)];
      String op2Asset = assetKeys[random.nextInt(assetKeys.length)];
      
      // Cevap seçenekleri oluştur
      Set<int> options = {correctAnswer};
      while (options.length < 4) {
        options.add(random.nextInt(10) + 1);
      }

      _questions.add({
        'num1': num1,
        'num2': num2,
        'op1Asset': op1Asset,
        'op2Asset': op2Asset,
        'isAddition': isAddition,
        'correctAnswer': correctAnswer,
        'options': options.toList()..shuffle(),
      });
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _speakQuestion() {
    final question = _questions[_currentQuestionIndex];
    final text = "${question['num1']} ${question['op1Asset']} ile ${question['num2']} ${question['op2Asset']} ${question['isAddition'] ? 'toplanırsa sonuç kaç olur?' : 'arasındaki fark kaçtır?'}";
    _speak(text);
  }

  void _checkAnswer(int selectedAnswer) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
    });

    final question = _questions[_currentQuestionIndex];
    final bool isCorrect = selectedAnswer == question['correctAnswer'];

    if (isCorrect) {
      _score++;
      _speak(correctMessages[Random().nextInt(correctMessages.length)]);
    } else {
      _speak(incorrectMessages[Random().nextInt(incorrectMessages.length)]);
    }

    // Sonraki soruya geç veya oyunu bitir
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isAnswered = false;
        });
        _speakQuestion();
      } else {
        _showEndGameDialog();
      }
    });
  }
  
  void _showEndGameDialog() {
    StatsService.incrementGamesPlayed();
    StatsService.awardBadge('Matematik');
    _confettiController.play();
    _speak("Tebrikler! Oyunu tamamladın ve harika bir rozet kazandın!");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Oyun Bitti!", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Harikasın!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Icon(Icons.star, color: Colors.amber, size: 80),
            const SizedBox(height: 16),
            Text("Skorun: $_score / 10", style: const TextStyle(fontSize: 20)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dialog'u kapat
              Navigator.of(context).pop(); // Oyun menüsüne dön
            },
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Soru Alanı
                  Expanded(
                    flex: 2,
                    child: _buildQuestionArea(question),
                  ),
                  // Cevap Alanı
                  Expanded(
                    flex: 3,
                    child: _buildAnswerArea(question),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea(Map<String, dynamic> question) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildQuestionItem(question['op1Asset'], question['num1']),
          Icon(
            question['isAddition'] ? Icons.add_circle_outline : Icons.remove_circle_outline,
            color: Colors.white,
            size: 50,
          ),
          _buildQuestionItem(question['op2Asset'], question['num2']),
          const Icon(
            Icons.drag_handle, // Eşittir işareti yerine
            color: Colors.white,
            size: 50,
          ),
          const Icon(
            Icons.help_outline,
            color: Colors.white,
            size: 80,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(String assetName, int count) {
    String? emoji = gameAssets[assetName];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji ?? '?',
          style: const TextStyle(fontSize: 60),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _buildAnswerArea(Map<String, dynamic> question) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final option = question['options'][index];
        return _buildAnswerCard(option);
      },
    );
  }

  Widget _buildAnswerCard(int option) {
    bool isCorrect = option == _questions[_currentQuestionIndex]['correctAnswer'];
    Color? cardColor;
    if(_isAnswered){
        cardColor = isCorrect ? Colors.lightGreenAccent : Colors.redAccent;
    }

    return GestureDetector(
      onTap: () => _checkAnswer(option),
      child: Card(
        color: cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Text(
            '$option',
            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
} 