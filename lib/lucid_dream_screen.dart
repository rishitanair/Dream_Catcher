import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LucidDreamScreen extends StatefulWidget {
  final bool isNight;
  const LucidDreamScreen({super.key, required this.isNight});

  @override
  State<LucidDreamScreen> createState() => _LucidDreamScreenState();
}

class _LucidDreamScreenState extends State<LucidDreamScreen> {
  final player = AudioPlayer();
  bool _isPlaying = false;
  int? _currentlyPlayingIndex;

  final List<String> images = [
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    'https://images.unsplash.com/photo-1532274402911-5a369e4c4bb5',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
  ];

  final List<Map<String, String>> sounds = [
    {
      'name': 'Ocean Waves',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    },
    {
      'name': 'Forest Ambience',
      'url': 'https://cdn.pixabay.com/audio/2022/03/15/audio_115b9b3b1b.mp3',
    },
    {
      'name': 'Rainfall',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    },
  ];

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _playSound(String url, int index) async {
    if (_isPlaying && _currentlyPlayingIndex == index) {
      await player.stop();
      setState(() {
        _isPlaying = false;
        _currentlyPlayingIndex = null;
      });
    } else {
      await player.play(UrlSource(url));
      setState(() {
        _isPlaying = true;
        _currentlyPlayingIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucid Dream Trainer'),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            widget.isNight ? Colors.indigo.shade900 : Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.isNight
                ? [
                    Colors.indigo.shade900,
                    Colors.purple.shade900,
                  ]
                : [
                    Colors.lightBlue.shade100,
                    Colors.white,
                  ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visual Triggers',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.isNight ? Colors.white : Colors.black,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Focus on these images before sleep to enhance dream awareness',
                style: TextStyle(
                    color: widget.isNight
                        ? Colors.grey.shade400
                        : Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          images[index],
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Audio Triggers',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.isNight ? Colors.white : Colors.black,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Play these sounds as you fall asleep to induce lucid dreams',
                style: TextStyle(
                    color: widget.isNight
                        ? Colors.grey.shade400
                        : Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ...List.generate(sounds.length, (index) {
                final sound = sounds[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: widget.isNight ? Colors.grey.shade800 : Colors.white,
                    child: ListTile(
                      onTap: () => _playSound(sound['url']!, index),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isPlaying && _currentlyPlayingIndex == index
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        sound['name']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: widget.isNight ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Tap to ${_isPlaying && _currentlyPlayingIndex == index ? 'stop' : 'play'}',
                        style: TextStyle(
                            color: widget.isNight
                                ? Colors.grey.shade400
                                : Colors.grey.shade600),
                      ),
                      trailing: Icon(
                        Icons.volume_up,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ).animate().fadeIn(delay: (150 * index).ms),
                );
              }),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: widget.isNight ? Colors.grey.shade800 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lucid Dreaming Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: widget.isNight ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• Practice reality checks during the day\n'
                        '• Keep a dream journal to improve recall\n'
                        '• Try the "MILD" technique before sleep\n'
                        '• Look for dream signs when you wake up\n'
                        '• Stay calm when you realize you\'re dreaming',
                        style: TextStyle(
                          fontSize: 15,
                          color: widget.isNight
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
