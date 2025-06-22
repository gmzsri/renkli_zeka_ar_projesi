import 'package:flutter/material.dart';
import 'package:renkli_zeka_ar_macera/screens/color_detective_screen.dart';
import 'package:renkli_zeka_ar_macera/screens/math_game_screen.dart';
import 'package:renkli_zeka_ar_macera/screens/memory_game_screen.dart';

class GameMenuScreen extends StatelessWidget {
  const GameMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Canlı Kart Renkleri
    final List<Color> cardColors = [
      Colors.orange.shade300,
      Colors.green.shade300,
      Colors.purple.shade300,
      Colors.red.shade300,
      Colors.blue.shade300,
    ];

    // Oyun verileri
    final List<Map<String, dynamic>> games = [
      {
        'title': 'Matematik Oyunu',
        'icon': Icons.calculate_rounded,
        'color': cardColors[0],
        'route': () => const MathGameScreen(),
      },
      {
        'title': 'Renk Dedektifi',
        'icon': Icons.colorize_rounded,
        'color': cardColors[1],
        'route': () => const ColorDetectiveScreen(),
      },
      {
        'title': 'Hafıza Oyunu',
        'icon': Icons.grid_view_rounded,
        'color': cardColors[2],
        'route': () => const MemoryGameScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyununu Seç'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          return _buildGameCard(context, games[index]);
        },
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> gameData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => gameData['route']()),
        );
      },
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: gameData['color'],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              gameData['icon'],
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              gameData['title'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 