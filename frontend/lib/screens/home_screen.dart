import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/controllers/stt_controller.dart';
import 'package:frontend/controllers/tts_controller.dart';
import 'package:frontend/controllers/translation_controller.dart';
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
  final TTSController _ttsController = TTSController();
  final TranslationController _translationController = TranslationController();

  String _spokenText = '';
  String selectedInputLang = "en";
  String selectedOutputLang = "hi";

  final Map<String, String> languageMap = {
    'English': 'en',
    'Hindi': 'hi',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Bengali': 'bn',
  };

  List<Map<String, dynamic>> chatMessages = [];

  late Timer _callTimer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
    _sttController.initialize();
    _ttsController.initialize();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      chatMessages.add({
        'text': text,
        'isUser': true,
        'time': TimeOfDay.now().format(context),
      });
    });
    _scrollToBottom();
    _textController.clear();
  }

  void _speakAndSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _ttsController.speak(text, langCode: selectedOutputLang);
    setState(() {
      chatMessages.add({
        'text': text,
        'isUser': true,
        'time': TimeOfDay.now().format(context),
      });
    });
    _scrollToBottom();
    _textController.clear();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _translateAndReplace(int index) async {
    final original = chatMessages[index]['text'];
    final translated = await _translationController.translateText(
      original,
      selectedInputLang,
      selectedOutputLang,
    );
    setState(() => chatMessages[index]['text'] = translated);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _callTimer.cancel();
    super.dispose();
  }

  Widget _buildDropdown(String langCode, ValueChanged<String?> onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: languageMap.entries.firstWhere((e) => e.value == langCode).key,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          onChanged: (newLangName) {
            if (newLangName != null) onChanged(languageMap[newLangName]);
          },
          items: languageMap.keys.map((langName) {
            return DropdownMenuItem<String>(
              value: langName,
              child: Text(langName),
            );
          }).toList(),
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
                const Text("Caller Name / Number",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(_formatDuration(_seconds),
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            const Divider(thickness: 1.5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDropdown(selectedInputLang,
                        (value) => setState(() => selectedInputLang = value!)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () {
                      setState(() {
                        final temp = selectedInputLang;
                        selectedInputLang = selectedOutputLang;
                        selectedOutputLang = temp;
                      });
                    },
                  ),
                  Expanded(
                    child: _buildDropdown(selectedOutputLang,
                        (value) => setState(() => selectedOutputLang = value!)),
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
                  return GestureDetector(
                    onTap: () async {
                      final result = await showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(100, 100, 0, 0),
                        items: const [
                          PopupMenuItem(value: 'copy', child: Text('Copy')),
                          PopupMenuItem(value: 'translate', child: Text('Translate')),
                        ],
                      );
                      if (result == 'copy') {
                        Clipboard.setData(ClipboardData(text: msg['text']));
                      } else if (result == 'translate') {
                        _translateAndReplace(index);
                      }
                    },
                    child: Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment:
                            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75),
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(msg['text'],
                                style: const TextStyle(fontSize: 16)),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 12, left: 12, bottom: 4),
                            child: Text(msg['time'],
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                          ),
                        ],
                      ),
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
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Type or Speak your message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.mic,
                        color: _sttController.isListening ? Colors.red : Colors.black),
                    onPressed: () async {
                      if (!_sttController.isListening) {
                        final langCode = '$selectedInputLang-IN';
                        await _sttController.startListening(
                          (text) {
                            setState(() {
                              _spokenText = text;
                              _textController.text = text;
                              _textController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: text.length));
                            });
                          },
                          () => debugPrint("Final: $_spokenText"),
                          langCode,
                        );
                      } else {
                        await _sttController.stop();
                      }
                    },
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
                  IconButton(
                      icon: const Icon(Icons.record_voice_over),
                      onPressed: _speakAndSend),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
