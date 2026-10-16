import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/speech_service.dart';
import '../widgets/chat_bubble.dart';

class GloveHomeScreen extends StatefulWidget {
  const GloveHomeScreen({super.key});

  @override
  State<GloveHomeScreen> createState() => _GloveHomeScreenState();
}

class _GloveHomeScreenState extends State<GloveHomeScreen> {
  final SpeechService _speechService = SpeechService();
  bool isListening = false;
  bool isConnected = true;

  final TextEditingController inputController = TextEditingController();

  final List<ChatMessage> conversation = [
    ChatMessage(
      text: 'I would like to go to the restroom, please.',
      isGlove: true,
      time: '10:14 AM',
    ),
    ChatMessage(
      text: "Sure, it's right down the hall.",
      isGlove: false,
      time: '10:15 AM',
    ),
  ];

  void _toggleListening() async {
    if (!isListening) {
      bool available = await _speechService.initSpeech();
      if (available) {
        setState(() => isListening = true);
        _speechService.startListening((recognizedText) {
          setState(() {
            inputController.text = recognizedText;
          });
        });
      }
    } else {
      setState(() => isListening = false);
      _speechService.stopListening();
      if (inputController.text.trim().isNotEmpty) {
        _appendMessage(inputController.text, false);
      }
    }
  }

  void _appendMessage(String msg, bool isGloveMsg) {
    if (msg.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      conversation.add(ChatMessage(
        text: msg,
        isGlove: isGloveMsg,
        time: timeStr,
      ));
    });
    inputController.clear();
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: conversation.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: conversation[index]);
              },
            ),
          ),
          const Divider(height: 1),
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
                  '2. Listener Speech Response:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: inputController,
                        decoration: InputDecoration(
                          hintText: isListening ? 'Listening...' : 'Type or tap mic...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          filled: true,
                          fillColor: isListening ? Colors.red.shade50 : Colors.white,
                        ),
                        onSubmitted: (val) => _appendMessage(val, false),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: isListening ? Colors.red : const Color(0xFF2E7D32),
                      ),
                      icon: Icon(inputController.text.isNotEmpty && !isListening ? Icons.send : (isListening ? Icons.mic : Icons.mic_none)),
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