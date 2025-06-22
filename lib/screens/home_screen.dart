import 'package:flutter/material.dart';
import 'package:renkli_zeka_ar_macera/screens/game_menu_screen.dart';
import 'package:renkli_zeka_ar_macera/screens/parent_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Örnek avatar resim yolları
    final List<String> avatarPaths = [
      'assets/images/avatar_1.png',
      'assets/images/avatar_2.png',
      'assets/images/avatar_3.png',
      'assets/images/avatar_4.png',
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Avatarını Seç',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Yan yana 2 avatar
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: avatarPaths.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Avatar seçildiğinde oyun menüsüne yönlendir
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GameMenuScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: ClipOval(
                            child: Image.asset(
                              avatarPaths[index],
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                              // Resim yüklenemezse görünecek olan hata widget'ı
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Ayarlar Butonu
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ParentDashboardScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 