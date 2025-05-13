import 'package:flutter/material.dart';
import 'package:frontend/controllers/stt_controller.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final STTController _sttController = STTController();
  String _spokenText = '';

  String selectedInputLang = "English";
  String selectedOutputLang = "Hindi";

  final List<String> languages = [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Bengali',
  ];

  List<Map<String, dynamic>> chatMessages = []; // {text: '', isUser: true, time: ''}

  late Timer _callTimer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
    _sttController.initialize();
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
        chatMessages.add({
          'text': _textController.text.trim(),
          'isUser': true,
          'time': TimeOfDay.now().format(context),
        });
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          menuStyle: MenuStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 120),
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              isExpanded: true,
              borderRadius: BorderRadius.circular(10),
              onChanged: onChanged,
              items: languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
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
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = chatMessages[index];
                  final isUser = msg['isUser'];
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (!isUser)
                              const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 14)),
                            Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.blue[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['text'],
                                softWrap: true,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            if (isUser)
                              const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.person, size: 14, color: Colors.white),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12, left: 12, bottom: 4),
                          child: Text(
                            msg['time'],
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 1.5),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 40, maxHeight: 150),
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (_) => _sendMessage(),
                        minLines: 1,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Type or Speak your message...",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.mic),
                            onPressed: () async {
                              if (!_sttController.isListening) {
                                await _sttController.startListening(
                                  (text) {
                                    setState(() {
                                      _spokenText = text;
                                      _textController.text = text;
                                      _textController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: _textController.text.length),
                                      );
                                    });
                                  },
                                  () {
                                    debugPrint("Final result: $_spokenText");
                                  },
                                  'en-IN',
                                );
                              } else {
                                await _sttController.stop();
                              }
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
