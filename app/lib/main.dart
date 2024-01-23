import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter 챗봇 예제'),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
          ),
          ChatBotButton(),
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
          padding: EdgeInsets.all(16.0),
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isChatBotOpen = !_isChatBotOpen;
              });
            },
            child: Icon(Icons.chat),
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

  ChatBotWidget({required this.onClose});

  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _chatMessages = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // 채팅창의 높이 조절
      decoration: BoxDecoration(
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
                    decoration: InputDecoration(
                      hintText: '메시지 입력',
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
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
    });
  }

  @override
  void initState() {
    super.initState();
    // 초기 채팅 메시지를 추가할 수 있습니다.
    _chatMessages.add(ChatMessage(isMe: false, message: '안녕하세요!'));
  }
}

class ChatMessage extends StatelessWidget {
  final bool isMe;
  final String message;

  ChatMessage({required this.isMe, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: isMe ? Colors.blue : Colors.green,
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
