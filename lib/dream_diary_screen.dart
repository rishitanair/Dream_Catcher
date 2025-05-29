import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'dart:convert';

class DreamDiaryScreen extends StatefulWidget {
  final bool isNight;
  const DreamDiaryScreen({super.key, required this.isNight});

  @override
  State<DreamDiaryScreen> createState() => _DreamDiaryScreenState();
}

class _DreamDiaryScreenState extends State<DreamDiaryScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> dreams = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late ConfettiController _confettiController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadDreams();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _loadDreams() async {
    final prefs = await SharedPreferences.getInstance();
    final dreamsString = prefs.getString('dreams');
    if (dreamsString != null) {
      final List decoded = jsonDecode(dreamsString);
      setState(() {
        dreams = decoded.cast<Map<String, dynamic>>().toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveDreamsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final dreamsString = jsonEncode(dreams);
    await prefs.setString('dreams', dreamsString);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _saveDream() {
    if (_formKey.currentState!.validate()) {
      var result = Sentiment.analysis(_controller.text);
      String feeling = 'Neutral 😐';
      Color feelingColor = Colors.blue;
      if (result.score > 0) {
        feeling = 'Happy 😊';
        feelingColor = Colors.green;
        _confettiController.play();
      }
      if (result.score < 0) {
        feeling = 'Sad 😢';
        feelingColor = Colors.red;
      }
      final now = DateTime.now();
      final formattedDate = '${now.day}/${now.month}/${now.year}';
      setState(() {
        dreams.add({
          'dream': _controller.text,
          'sentiment': feeling,
          'color': feelingColor.value.toRadixString(16),
          'date': formattedDate,
          'timestamp': now.millisecondsSinceEpoch,
        });
        _controller.clear();
      });
      _saveDreamsToStorage();
    }
  }

  Widget _buildDreamCard(Map<String, dynamic> dream, int index) {
    final color = Color(int.parse(dream['color'], radix: 16));
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
              color.withAlpha(50),
              color.withAlpha(15),
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
                    dream['date'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    dream['sentiment'],
                    style: TextStyle(
                      fontSize: 24,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                dream['dream'],
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
        title: const Text('Dream Diary'),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            widget.isNight ? Colors.indigo.shade900 : Colors.blue.shade700,
      ),
      body: Stack(
        children: [
          Container(
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
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Describe your dream...',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isListening
                                    ? Icons.mic
                                    : Icons.mic_none_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: _listen,
                            ),
                            prefixIcon: Icon(
                              Icons.nightlight_round,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please describe your dream';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveDream,
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
                            'Save Dream',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (dreams.isEmpty)
                    Column(
                      children: [
                        Image.asset(
                          'C:/Users/PC-LENOVO/Desktop/Dev/flutter/dreamcatcher_app/assets/i_got_nothing.png',
                          height: 150,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No dreams recorded yet',
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
                          'Your Dream History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.isNight ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...dreams.reversed
                            .map((dream) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _buildDreamCard(
                                      dream, dreams.indexOf(dream)),
                                ))
                            .toList(),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }
}
