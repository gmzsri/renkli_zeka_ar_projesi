import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// Rozetlerin yapısını tanımlayan basit bir sınıf
class Badge {
  final String name;
  final IconData icon;
  final Color color;

  Badge({required this.name, required this.icon, required this.color});
}

class StatsService {
  static late SharedPreferences _prefs;

  // Tüm oyunların rozet tanımları
  static final Map<String, Badge> allBadges = {
    'Matematik': Badge(name: 'Matematik Ustası', icon: Icons.calculate, color: Colors.orange),
    'Hafıza': Badge(name: 'Hafıza Şampiyonu', icon: Icons.grid_view_rounded, color: Colors.blue),
    'Renk': Badge(name: 'Renk Dedektifi', icon: Icons.colorize, color: Colors.green),
  };

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Oynanan oyun sayısını artır
  static Future<void> incrementGamesPlayed() async {
    int currentCount = _prefs.getInt('gamesPlayed') ?? 0;
    await _prefs.setInt('gamesPlayed', currentCount + 1);
  }

  // Toplam oyun sayısını getir
  static int getGamesPlayed() {
    return _prefs.getInt('gamesPlayed') ?? 0;
  }
  
  // Yeni bir rozet ekle
  static Future<void> awardBadge(String gameName) async {
    final List<String> currentBadges = _prefs.getStringList('earnedBadges') ?? [];
    if (!currentBadges.contains(gameName)) {
      currentBadges.add(gameName);
      await _prefs.setStringList('earnedBadges', currentBadges);
    }
  }

  // Kazanılan rozetleri getir
  static List<Badge> getEarnedBadges() {
    final List<String> badgeNames = _prefs.getStringList('earnedBadges') ?? [];
    return badgeNames.map((name) => allBadges[name]!).toList();
  }

  // Toplam rozet sayısını getir
  static int getBadgesCount() {
    return (_prefs.getStringList('earnedBadges') ?? []).length;
  }
  
  // Uygulamada geçirilen süreyi güncelle
  static Future<void> addSessionTime(int seconds) async {
    // Bugünün anahtarını oluştur (örn: 'session_2023-10-27')
    String todayKey = 'session_${DateTime.now().toIso8601String().split('T').first}';
    int todaySeconds = _prefs.getInt(todayKey) ?? 0;
    await _prefs.setInt(todayKey, todaySeconds + seconds);

    // Haftalık toplamı da güncelle... Bu daha karmaşık olduğu için şimdilik sadece günlük
  }

  // Bugün geçirilen süreyi getir
  static int getSessionTimeToday() {
     String todayKey = 'session_${DateTime.now().toIso8601String().split('T').first}';
     return _prefs.getInt(todayKey) ?? 0;
  }
} 