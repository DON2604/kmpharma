import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HealthTips extends StatefulWidget {
  const HealthTips({super.key});

  @override
  State<HealthTips> createState() => _HealthTipsState();
}

class _HealthTipsState extends State<HealthTips> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  int _currentVideoIndex = 0;

  final List<Map<String, String>> _healthVideos = [
    {
      'id': 'xyQY8a-ng6g',
      'title': 'How the food you eat affects your brain - Mia Nacamulli',
      'description': 'When it comes to what you bite, chew and swallow, your choices have a direct and long-lasting effect on the most powerful organ in your body: your brain. So which foods cause you to feel so tired after lunch?',
    },
    {
      'id': 'HBWydCNV-fQ',
      'title': 'The 6 PROVEN Ways to Heal Your Gut',
      'description': 'Understanding proper nutrition',
    },
    {
      'id': 'Y8HIFRPU6pM',
      'title': 'How to EASILY Kick Start A Healthy Lifestyle FAST!!',
      'description': 'Basic exercises for better health',
    },
    {
      'id': '75d_29QWELk',
      'title': 'Change Your Life – One Tiny Step at a Time',
      'description': 'Tips for mental health',
    },
    {
      'id': 'Mo1A45ShcMo',
      'title': 'Youa re More Stressed Than Ever - Let us Change That',
      'description': 'Improve your sleep quality',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _healthVideos.first['id']!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        disableDragSeek: false,
        forceHD: false,
        loop: false,
        isLive: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playVideo(int index) {
    if (index == _currentVideoIndex) return;

    setState(() => _currentVideoIndex = index);
    _controller.load(_healthVideos[index]['id']!);
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        progressIndicatorColor: Colors.green,
        showVideoProgressIndicator: true,
        onReady: () => _isPlayerReady = true,
        onEnded: (_) {
          if (_currentVideoIndex < _healthVideos.length - 1) {
            _playVideo(_currentVideoIndex + 1);
            _showSnackBar('Next health tip started');
          }
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text('Health Tips'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ---- PLAYER CONTAINER (FIXED OVERLAP) ----
                Container(
                  color: Colors.black,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: player,
                  ),
                ),

                // ---- LIST ----
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _healthVideos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final video = _healthVideos[index];
                      final isActive = index == _currentVideoIndex;

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _playVideo(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isActive
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              child: Icon(
                                Icons.play_arrow,
                                color: isActive
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                            title: Text(
                              video['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.green.shade700
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              video['description']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
