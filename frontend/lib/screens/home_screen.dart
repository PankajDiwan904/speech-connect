import 'package:flutter/material.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String selectedInputLang = "English";
  String selectedOutputLang = "Hindi";

  final List<String> languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Bengali'];

  List<String> chatMessages = [];

  // Timer
  late Timer _callTimer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        chatMessages.add(_textController.text.trim());
        _textController.clear();
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = selectedInputLang;
      selectedInputLang = selectedOutputLang;
      selectedOutputLang = temp;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _callTimer.cancel();
    super.dispose();
  }

Widget _buildDropdown(String value, ValueChanged<String?> onChanged) {
  return Theme(
    data: Theme.of(context).copyWith(
      canvasColor: Colors.white,
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        menuStyle: MenuStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    ),
    child: Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: ConstrainedBox(constraints: const BoxConstraints.tightFor(width: 120),
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          borderRadius: BorderRadius.circular(10), // Match the container
          onChanged: onChanged,
          items: languages
              .map((lang) => DropdownMenuItem(
                    value: lang,
                    child: Text(lang),
                  ))
              .toList(),
        ),
      ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Caller info with dynamic timer
            Column(
              children: [
                const Text(
                  "Caller Name / Number",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDuration(_seconds),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const Divider(thickness: 1.5),

            // Dropdown Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDropdown(selectedInputLang, (value) {
                      if (value != null) {
                        setState(() => selectedInputLang = value);
                      }
                    }),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, size: 28),
                    onPressed: _swapLanguages,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildDropdown(selectedOutputLang, (value) {
                      if (value != null) {
                        setState(() => selectedOutputLang = value);
                      }
                    }),
                  ),
                ],
              ),
            ),

            // Chat Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(chatMessages[index]),
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 1.5),

            // Input row
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.mic, size: 26),
                    onPressed: () {
                      // TODO: Voice recording logic
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, size: 26),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
