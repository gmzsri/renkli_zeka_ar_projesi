import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:renkli_zeka_ar_macera/services/stats_service.dart';

// Oyun için kullanılacak emoji listesi (18 çift)
final List<String> gameEmojis = [
  '🍎', '🍌', '🍇', '🍓', '🍍', '🍉',
  '🐘', '🦒', '🐒', '🦁', '🐧', '🦓',
  '🦋', '🐢', '🐬', '🚗', '🚀', '🎈',
];

// Motivasyonel sesli mesajlar
const List<String> correctMessages = ['Harika bir eşleştirme!', 'Süpersin!', 'İşte bu!', 'Bravo, devam et!'];
const List<String> incorrectMessages = ['Tekrar deneyelim.', 'Neredeyse oluyordu.', 'Haydi bir daha!'];


class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  
  late List<String> _shuffledEmojis;
  late List<bool> _isCardFlipped;
  List<int> _flippedCardIndices = [];
  int _matchedPairs = 0;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _setupTts();
    _startGame();
  }

  void _startGame() {
    _shuffledEmojis = [...gameEmojis, ...gameEmojis]..shuffle();
    _isCardFlipped = List<bool>.filled(36, false);
    _flippedCardIndices = [];
    _matchedPairs = 0;
    _isChecking = false;
  }
  
  void _setupTts() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.2);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _onCardTapped(int index) {
    // Eğer kontrol yapılıyorsa veya kart zaten açıksa işlem yapma
    if (_isChecking || _isCardFlipped[index]) return;

    setState(() {
      _isCardFlipped[index] = true;
      _flippedCardIndices.add(index);
    });

    if (_flippedCardIndices.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    setState(() {
      _isChecking = true;
    });

    final int index1 = _flippedCardIndices[0];
    final int index2 = _flippedCardIndices[1];
    final bool isMatch = _shuffledEmojis[index1] == _shuffledEmojis[index2];

    Timer(const Duration(milliseconds: 1000), () {
      if (isMatch) {
        _speak(correctMessages[Random().nextInt(correctMessages.length)]);
        setState(() {
          _matchedPairs++;
          // Eşleşen kartları açık bırak, ama dokunulmaz yap
          // Bu örnekte, _isCardFlipped zaten true kalacak
        });
        if (_matchedPairs == gameEmojis.length) {
          _showWinDialog();
        }
      } else {
        _speak(incorrectMessages[Random().nextInt(incorrectMessages.length)]);
        setState(() {
          _isCardFlipped[index1] = false;
          _isCardFlipped[index2] = false;
        });
      }
      setState(() {
        _flippedCardIndices = [];
        _isChecking = false;
      });
    });
  }
  
  void _showWinDialog() {
    StatsService.incrementGamesPlayed();
    StatsService.awardBadge('Hafıza');
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
          children: const [
            Text("Harikasın!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Icon(Icons.emoji_events, color: Colors.amber, size: 100),
            SizedBox(height: 16),
            Text("Yeni bir rozet kazandın!", style: TextStyle(fontSize: 20)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dialog'u kapat
              Navigator.of(context).pop(); // Oyun menüsüne dön
            },
            child: const Text("Harika!"),
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1, // Kare bir alan oluşturur
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(), // Kaydırmayı engelle
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 36,
                    itemBuilder: (context, index) {
                      return _buildCard(index);
                    },
                  ),
                ),
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

  Widget _buildCard(int index) {
    final bool isFlipped = _isCardFlipped[index];
    
    return GestureDetector(
      onTap: () => _onCardTapped(index),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isFlipped ? Colors.white : Colors.lightBlue.shade200,
        child: Center(
          child: isFlipped
              ? Text(
                  _shuffledEmojis[index],
                  style: const TextStyle(fontSize: 40),
                )
              : const Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white,
                  size: 40,
                ),
        ),
      ),
    );
  }
} 