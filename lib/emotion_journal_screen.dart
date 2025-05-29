import 'package:flutter/material.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class EmotionJournalScreen extends StatefulWidget {
  final bool isNight;
  const EmotionJournalScreen({super.key, required this.isNight});

  @override
  State<EmotionJournalScreen> createState() => _EmotionJournalScreenState();
}

class _EmotionJournalScreenState extends State<EmotionJournalScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString('emotion_entries');
    if (entriesString != null) {
      final List<dynamic> decoded = jsonDecode(entriesString);
      setState(() {
        entries = decoded.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveEntriesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = jsonEncode(entries);
    await prefs.setString('emotion_entries', entriesString);
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      var result = Sentiment.analysis(_controller.text);
      String feeling = 'Neutral 😐';
      Color feelingColor = Colors.blue;
      if (result.score > 0) {
        feeling = 'Happy 😊';
        feelingColor = Colors.green;
      }
      if (result.score < 0) {
        feeling = 'Sad 😢';
        feelingColor = Colors.red;
      }
      String now = DateFormat('EEE, MMM d • h:mm a').format(DateTime.now());
      setState(() {
        entries.add({
          'entry': _controller.text,
          'sentiment': feeling,
          'color': feelingColor.value.toRadixString(16),
          'datetime': now,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        _controller.clear();
      });
      _saveEntriesToStorage();
    }
  }

  Widget _buildEmotionCard(Map<String, dynamic> entry, int index) {
    final color = Color(int.parse(entry['color'], radix: 16));
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry['datetime'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    entry['sentiment'],
                    style: TextStyle(
                      fontSize: 24,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry['entry'],
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(
          begin: -0.2,
          end: 0,
          duration: 300.ms,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Journal'),
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
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controller,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'How are you feeling today?',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.emoji_emotions,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please share your feelings';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: widget.isNight
                            ? Colors.purple.shade700
                            : Colors.blue.shade500,
                      ),
                      child: const Text(
                        'Save Entry',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (entries.isEmpty)
                Column(
                  children: [
                    Image.asset(
                      'C:/Users/PC-LENOVO/Desktop/Dev/flutter/dreamcatcher_app/assets/i_got_nothing.png',
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No entries yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: widget.isNight
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Your Emotion History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.isNight ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...entries.reversed
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildEmotionCard(
                                  entry, entries.indexOf(entry)),
                            ))
                        .toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
