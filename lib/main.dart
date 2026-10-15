import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Sign Assist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const GloveHomeScreen(),
    );
  }
}

class GloveHomeScreen extends StatefulWidget {
  const GloveHomeScreen({super.key});

  @override
  State<GloveHomeScreen> createState() => _GloveHomeScreenState();
}

class _GloveHomeScreenState extends State<GloveHomeScreen> {
  // Speech recognition instance
  late stt.SpeechToText _speech;
  bool isListening = false;
  String spokenTextBuffer = '';

  // BLE status (TODO: connect to flutter_blue_plus stream when hardware arrives)
  bool isConnected = true;
  final TextEditingController inputController = TextEditingController();

  // Chat log: true = Glove gesture (user), false = Listener speech
  final List<Map<String, dynamic>> conversation = [
    {
      'text': 'I would like to go to the restroom, please.',
      'isGlove': true,
      'time': '10:14 AM',
    },
    {
      'text': "Sure, it's right down the hall.",
      'isGlove': false,
      'time': '10:15 AM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Toggle live mic capture using speech_to_text
  void _toggleListening() async {
    if (!isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => isListening = false);
          }
        },
        onError: (error) => setState(() => isListening = false),
      );

      if (available) {
        setState(() => isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              spokenTextBuffer = result.recognizedWords;
              inputController.text = spokenTextBuffer; // Live text update
            });
          },
        );
      }
    } else {
      setState(() => isListening = false);
      _speech.stop();
      if (spokenTextBuffer.trim().isNotEmpty) {
        _appendMessage(spokenTextBuffer, false);
        spokenTextBuffer = '';
      }
    }
  }

  void _appendMessage(String msg, bool isGloveMsg) {
    if (msg.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      conversation.add({
        'text': msg,
        'isGlove': isGloveMsg,
        'time': timeStr,
      });
    });
    inputController.clear();
    spokenTextBuffer = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Smart Sign Assist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: isConnected ? Colors.lightGreenAccent : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  isConnected ? 'Glove Connected' : 'Offline',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Informational bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.green.shade50,
            child: const Row(
              children: [
                Icon(Icons.sync_alt, color: Color(0xFF2E7D32), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Translating glove hand gestures to speech & transcribing listener response.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // Conversation Stream
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: conversation.length,
              itemBuilder: (context, index) {
                final item = conversation[index];
                final isGlove = item['isGlove'] as bool;

                return Align(
                  alignment: isGlove ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isGlove ? Colors.blue.shade50 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isGlove ? Colors.blue.shade200 : Colors.green.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGlove ? Icons.back_hand : Icons.record_voice_over,
                              size: 14,
                              color: isGlove ? Colors.blue.shade800 : Colors.green.shade800,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isGlove ? 'Glove Gesture (Spoken)' : 'Listener Speech (Text)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isGlove ? Colors.blue.shade900 : Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['text'],
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Action Controls Panel
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. Glove Motion Data (Simulated BLE Input):',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        avatar: const Text('🚽'),
                        label: const Text('Restroom'),
                        onPressed: () => _appendMessage('I would like to go to the restroom, please.', true),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Text('🍔'),
                        label: const Text('Order Food'),
                        onPressed: () => _appendMessage('Could I please order some food?', true),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Text('🧭'),
                        label: const Text('Directions'),
                        onPressed: () => _appendMessage('Excuse me, could you give me directions?', true),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Text('🙏'),
                        label: const Text('Thank You'),
                        onPressed: () => _appendMessage('Thank you so much!', true),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  '2. Listener Speech Response (Live Mic Transcribe):',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: inputController,
                        decoration: InputDecoration(
                          hintText: isListening ? 'Listening...' : 'Type or tap mic to capture speech...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: isListening ? Colors.red.shade50 : Colors.white,
                        ),
                        onSubmitted: (val) => _appendMessage(val, false),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Send text manually or record live audio
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: isListening ? Colors.red : const Color(0xFF2E7D32),
                      ),
                      icon: Icon(
                        inputController.text.isNotEmpty && !isListening
                            ? Icons.send
                            : (isListening ? Icons.mic : Icons.mic_none),
                      ),
                      onPressed: () {
                        if (inputController.text.isNotEmpty && !isListening) {
                          _appendMessage(inputController.text, false);
                        } else {
                          _toggleListening();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}