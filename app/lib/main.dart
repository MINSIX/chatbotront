import 'dart:async';
import 'dart:convert';
import "package:flutter/material.dart";
// ignore: depend_on_referenced_packages
import "package:http/http.dart" as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
}

class ChatBotButton extends StatefulWidget {
  const ChatBotButton({Key? key}) : super(key: key);

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
                ? Container()
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

  const ChatBotWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
              reverse: false,
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

  Future<void> _sendMessage(String message) async {
    setState(() {
      _chatMessages.add(ChatMessage(isMe: true, message: message));
      _messageController.clear();
    });

    await _sendToServer(message);
  }

  Future<void> _sendToServer(String message) async {
    String serverUrl = 'http://127.0.0.1:5000/receive_message';

    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {

      print('server reponse:${response.body}');
 //  // JSON 디코딩
      dynamic decodedResponse = json.decode(response.body);

// 디코딩된 결과 출력
      print(decodedResponse);

// 디코딩된 결과를 사용하여 채팅창 업데이트 등의 작업 수행
      _updateChatMessages(decodedResponse.toString());
     
    } else {
      print('Error sending message to the server');
    }
  }

  void _updateChatMessages(String replyMessage) {
    setState(() {
      String msg=replyMessage.replaceAll('"', '');
     _chatMessages.add(ChatMessage(isMe: false, message: msg));

    });
  }

  @override
  void initState() {
    super.initState();
    _chatMessages.add(const ChatMessage(isMe: false, message: '안녕하세요! 저는 챗봇입니다. 하고 싶은 말이 무엇인가요?'));
  }
}

class ChatMessage extends StatelessWidget {
  final bool isMe;
  final String message;

  const ChatMessage({Key? key, required this.isMe, required this.message}) : super(key: key);

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
