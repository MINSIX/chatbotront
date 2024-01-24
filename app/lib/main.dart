import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 챗봇 예제'),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
          ),
          const ChatBotButton(),
        ],
      ),
    );
  }

  void _showChatBot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ChatBotWidget(onClose: () {
            Navigator.pop(context);
          }),
        );
      },
    );
  }
}

class ChatBotButton extends StatefulWidget {
  const ChatBotButton({super.key});

  @override
  _ChatBotButtonState createState() => _ChatBotButtonState();
}

class _ChatBotButtonState extends State<ChatBotButton> {
  bool _isChatBotOpen = false;

  @override
  Widget build(BuildContext context) {
    double maxHeight = MediaQuery.of(context).size.height * 2 / 3;

    return Stack(
      children: [
        if (_isChatBotOpen)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
              ),
              child: ChatBotWidget(onClose: _closeChatBot),
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isChatBotOpen
                ? Container()  // 채팅창이 열려있을 때는 빈 컨테이너를 표시
                : FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _isChatBotOpen = true;
                      });
                    },
                    child: const Icon(Icons.chat),
                  ),
          ),
        ),
      ],
    );
  }

  void _closeChatBot() {
    setState(() {
      _isChatBotOpen = false;
    });
  }
}


class ChatBotWidget extends StatefulWidget {
  final VoidCallback onClose;

  const ChatBotWidget({super.key, required this.onClose});

  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // 채팅창의 높이 조절
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false, // 리스트 역순으로 배치
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                return _chatMessages[index];
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '메시지 입력',
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _sendMessage(_messageController.text);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
  setState(() {
    _chatMessages.add(ChatMessage(isMe: true, message: message));
    _messageController.clear();

    // 서버로 채팅 메시지 전송
    _sendToServer(message);
  });
}

void _sendToServer(String message) async {
  // 서버 URL을 적절히 변경해야 합니다.
  String serverUrl = 'http://127.0.0.1:5000/receive_message';

  // 서버에 메시지 전송
  await http.post(
    Uri.parse(serverUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'message': message}),
  );
}

  @override
  void initState() {
    super.initState();
    // 초기 채팅 메시지를 추가할 수 있습니다.
    _chatMessages.add(const ChatMessage(isMe: false, message: '안녕하세요! 저는 챗봇입니다. 하고 싶은 말이 무엇인가요?'));
  }
}

class ChatMessage extends StatelessWidget {
  final bool isMe;
  final String message;

  const ChatMessage({super.key, required this.isMe, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: isMe ? Colors.blue : Colors.green,
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
