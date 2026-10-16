import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isGlove = message.isGlove;

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
              message.text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}