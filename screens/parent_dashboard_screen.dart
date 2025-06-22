import 'package:flutter/material.dart';
import 'package:renkli_zeka_ar_macera/services/stats_service.dart' as stats;

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  // Verileri tutmak için state değişkenleri
  int _gamesPlayed = 0;
  int _badgesCount = 0;
  int _sessionTimeToday = 0;
  List<stats.Badge> _earnedBadges = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _gamesPlayed = stats.StatsService.getGamesPlayed();
      _badgesCount = stats.StatsService.getBadgesCount();
      _sessionTimeToday = stats.StatsService.getSessionTimeToday();
      _earnedBadges = stats.StatsService.getEarnedBadges();
    });
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;
    return '${minutes}dk ${seconds}sn';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ebeveyn Paneli'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildBadgesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genel İstatistikler',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            _buildStatCard('Toplam Oynanan Oyun', _gamesPlayed.toString(), Icons.gamepad),
            _buildStatCard('Bugünkü Süre', _formatDuration(_sessionTimeToday), Icons.timer),
            _buildStatCard('Kazanılan Rozet Sayısı', _badgesCount.toString(), Icons.emoji_events),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 160,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kazanılan Rozetler',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        _earnedBadges.isEmpty
            ? const Text('Henüz hiç rozet kazanılmadı.')
            : Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: _earnedBadges.map((badge) => _buildBadge(badge)).toList(),
              ),
      ],
    );
  }

  Widget _buildBadge(stats.Badge badge) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: badge.color.withOpacity(0.2),
        child: Icon(badge.icon, size: 18, color: badge.color),
      ),
      label: Text(badge.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: badge.color.withOpacity(0.1),
      side: BorderSide(color: badge.color.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
} 