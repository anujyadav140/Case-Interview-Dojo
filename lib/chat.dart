import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dummy Chat UI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatPage(
        onSpeechResult: (speech) {
          // Handle recognized speech text here
          print('Recognized speech: $speech');
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final ValueChanged<String> onSpeechResult;
  const ChatPage({super.key, required this.onSpeechResult});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Hey there!', isMe: false),
    _ChatMessage(text: 'Hello! How are you?', isMe: true),
    _ChatMessage(text: 'I’m good, thanks! And you?', isMe: false),
    _ChatMessage(text: 'Doing well—working on a Flutter project.', isMe: true),
    _ChatMessage(text: 'Nice! Let me know if you need help.', isMe: false),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  double _soundLevel = 0.0;
  String _speechText = ''; // holds all speech-to-text results

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMicPermissionDialog();
    });
  }

  void _showMicPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Turn on the mic?'),
        content: const Text(
          'We’ll start listening as soon as you tap OK.\n\n'
          'You can stop/start listening anytime by tapping the mic icon up top.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _toggleListening();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text, {bool isMe = true}) {
    setState(() => _messages.add(_ChatMessage(text: text, isMe: isMe)));
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _onSendPressed() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _sendMessage(text, isMe: true);
    Future.delayed(const Duration(milliseconds: 300), () {
      _sendMessage('Got your message: "\$text"', isMe: false);
    });
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if ((status == 'done' || status == 'notListening') && _isListening) {
            _startListening();
          }
        },
        onError: (error) {
          if (_isListening) _startListening();
        },
      );
      if (available) {
        setState(() {
          _isListening = true;
          _soundLevel = 0.0;
        });
        _startListening();
      }
    } else {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) async {
        final spoken = result.recognizedWords;
        // update speech text variable and the input field
        setState(() {
          _speechText = spoken;
          _controller.text = spoken;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: spoken.length),
          );
        });

        if (result.finalResult) {
          _controller.clear();
          // send the accumulated speech text
          _sendMessage(_speechText, isMe: true);
          // pass the speech text up to the parent widget
          widget.onSpeechResult(_speechText);

          await Future.delayed(const Duration(milliseconds: 300));
          _sendMessage('Got your message: "\$_speechText"', isMe: false);
        }
      },
      listenFor: const Duration(minutes: 10),
      pauseFor: const Duration(seconds: 60),
      partialResults: true,
      cancelOnError: true,
      onSoundLevelChange: (level) {
        setState(() {
          _soundLevel = ((level + 50) / 50).clamp(0.0, 1.0);
        });
      },
    );
  }

  Widget buildMicButton() {
    final icon = Icon(
      _isListening ? Icons.mic : Icons.mic_none,
      size: 28,
      color: _isListening ? Colors.blue : Colors.grey,
    );
    if (_isListening) {
      final scale = 1.0 + (_soundLevel * 0.5);
      return AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
        child: IconButton(icon: icon, onPressed: _toggleListening),
      );
    } else {
      return IconButton(icon: icon, onPressed: _toggleListening);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dummy Chat UI'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) {
                  final msg = _messages[i];
                  return Align(
                    alignment: msg.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isMe
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft:
                              Radius.circular(msg.isMe ? 12 : 0),
                          bottomRight:
                              Radius.circular(msg.isMe ? 0 : 12),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  buildMicButton(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _onSendPressed(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _onSendPressed,
                    color: Colors.blue,
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

class _ChatMessage {
  final String text;
  final bool isMe;
  _ChatMessage({required this.text, this.isMe = false});
}
