import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:image/image.dart' as img;
import 'package:renkli_zeka_ar_macera/services/stats_service.dart';

// Aranacak renkler ve Türkçe isimleri
const Map<String, Color> targetColors = {
  'kırmızı': Colors.red,
  'yeşil': Colors.green,
  'mavi': Colors.blue,
  'sarı': Colors.yellow,
  'turuncu': Colors.orange,
  'mor': Colors.purple,
};

// Motivasyonel sesli mesajlar
const List<String> correctMessages = ['Harikasın!', 'Doğru renk!', 'Süper!', 'İşte bu!'];
const List<String> incorrectMessages = ['Tekrar deneyelim mi?', 'Hmm, bu o renk değil.', 'Haydi başka bir nesne bulalım.'];

class ColorDetectiveScreen extends StatefulWidget {
  const ColorDetectiveScreen({super.key});

  @override
  State<ColorDetectiveScreen> createState() => _ColorDetectiveScreenState();
}

class _ColorDetectiveScreenState extends State<ColorDetectiveScreen> {
  CameraController? _cameraController;
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  
  bool _isCameraInitialized = false;
  String _targetColorName = '';
  Color _targetColor = Colors.transparent;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _setupTts();
    _initializeCamera();
  }

  Future<void> _setupTts() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setPitch(1.2);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
      _startNewRound();
    } catch (e) {
      print("Kamera başlatılırken hata: $e");
    }
  }

  void _startNewRound() {
    final randomColorName = targetColors.keys.toList()[Random().nextInt(targetColors.length)];
    setState(() {
      _targetColorName = randomColorName;
      _targetColor = targetColors[randomColorName]!;
    });
    _flutterTts.speak('Haydi $_targetColorName rengini bulalım!');
  }

  Future<void> _analyzeColor() async {
    if (_isProcessing || !_cameraController!.value.isInitialized) return;

    setState(() { _isProcessing = true; });

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final bytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        // Görüntünün merkezindeki pikselin rengini al
        final pixel = image.getPixel(image.width ~/ 2, image.height ~/ 2);
        Color detectedColor = Color.fromRGBO(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt(), 1.0);
        
        // Renkleri karşılaştır
        bool isMatch = _isColorMatch(detectedColor, _targetColor);
        if (isMatch) {
          _handleWin();
        } else {
          _flutterTts.speak(incorrectMessages[Random().nextInt(incorrectMessages.length)]);
        }
      }
    } catch (e) {
      print("Renk analizi sırasında hata: $e");
    } finally {
      setState(() { _isProcessing = false; });
    }
  }

  bool _isColorMatch(Color color1, Color color2, {int tolerance = 80}) {
    // RGB uzayında basit bir Öklid mesafesi hesaplaması
    var r = color1.red - color2.red;
    var g = color1.green - color2.green;
    var b = color1.blue - color2.blue;
    var distance = sqrt(r*r + g*g + b*b);
    return distance < tolerance;
  }

  void _handleWin() {
    StatsService.incrementGamesPlayed();
    StatsService.awardBadge('Renk');
    _confettiController.play();
    _flutterTts.speak("Tebrikler! $_targetColorName rengini buldun!");
    
    Future.delayed(const Duration(seconds: 3), () {
        if(mounted) {
            Navigator.of(context).pop();
        }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _confettiController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Kamera Önizlemesi
          if (_isCameraInitialized && _cameraController!.value.isInitialized)
            Positioned.fill(child: CameraPreview(_cameraController!))
          else
            const Center(child: CircularProgressIndicator()),

          // Hedefleme ve UI
          _buildUIOverlay(),

          // Konfeti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUIOverlay() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Üstteki Renk Bilgisi
          Card(
            color: _targetColor.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                _targetColorName.toUpperCase(),
                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // Ortadaki Hedef Halkası
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(50),
              color: Colors.white.withOpacity(0.2),
            ),
          ),

          // Alttaki Analiz Butonu
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: ElevatedButton(
              onPressed: _analyzeColor,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.white,
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : Icon(Icons.colorize, color: _targetColor, size: 40),
            ),
          ),
        ],
      ),
    );
  }
} 