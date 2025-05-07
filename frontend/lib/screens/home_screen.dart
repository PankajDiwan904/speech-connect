import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Connect'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hearing, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.mic),
              label: Text('Start Listening'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
              ),
              onPressed: () {
                // TODO: Trigger speech-to-text
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.volume_up),
              label: Text('Speak Message'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
              ),
              onPressed: () {
                // TODO: Trigger text-to-speech
              },
            ),
          ],
        ),
      ),
    );
  }
}
