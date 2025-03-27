import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_client/web_socket_client.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.name, required this.id}) : super(key: key);

  final String name;
  final String id;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final socket = WebSocket(Uri.parse('ws://localhost:8765'));
  final List<types.Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  late types.User otherUser;
  late types.User me;

  @override
  void initState() {
    super.initState();

    me = types.User(
      id: widget.id,
      firstName: widget.name,
    );

    socket.messages.listen((incomingMessage) {
      List<String> parts = incomingMessage.split(' from ');
      String jsonString = parts[0];
      Map<String, dynamic> data = jsonDecode(jsonString);
      String id = data['id'];
      String msg = data['msg'];
      String nick = data['nick'] ?? id;
      bool isImage = data['isImage'] ?? false;

      if (id != me.id) {
        otherUser = types.User(
          id: id,
          firstName: nick,
        );
        onMessageReceived(msg, isImage);
      }
    }, onError: (error) {
      print("WebSocket error: $error");
    });
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  

String _saveImage(Uint8List imageBytes) {
  final blob = html.Blob([imageBytes]);  
  final url = html.Url.createObjectUrlFromBlob(blob);  // Cria uma URL temporária
  return url;
}



  void onMessageReceived(String message, bool isImage) async {
  types.Message newMessage;

  if (isImage) {
    Uint8List imageBytes = base64Decode(message);
    String filePath = _saveImage(imageBytes);

    newMessage = types.ImageMessage(
  author: otherUser,
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'received_image.jpg',
  size: imageBytes.length,
  uri: filePath,  // URL temporária da imagem
  createdAt: DateTime.now().millisecondsSinceEpoch,
  metadata: {'isImage': true},
);
  } else {
    newMessage = types.TextMessage(
      author: otherUser,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      metadata: {'isImage': false},
    );
  }

  _addMessage(newMessage);
}


  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _sendMessageCommon(String text, {bool isImage = false}) async {
  types.Message textMessage;

  if (isImage) {
    Uint8List imageBytes = base64Decode(text);
    String filePath;

      // 🌐 Web: Criar uma URL temporária
      filePath = _saveImage(imageBytes);

    textMessage = types.ImageMessage(
      author: me,
      id: randomString(),
      name: 'sent_image.jpg',
      size: imageBytes.length,
      uri: filePath,  // 🟢 Caminho correto da imagem
      createdAt: DateTime.now().millisecondsSinceEpoch,
      metadata: {'isImage': true},
    );
  } else {
    textMessage = types.TextMessage(
      author: me,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: text,
      metadata: {'isImage': false},
    );
  }

  // Envia para o WebSocket
  var payload = {
    'id': me.id,
    'msg': text,
    'nick': me.firstName,
    'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    'isImage': isImage,
  };

  socket.send(json.encode(payload));

  // Adiciona a mensagem na UI do chat
  _addMessage(textMessage);
}


  void _handleSendPressed(types.PartialText message) {
    _sendMessageCommon(message.text);
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Uint8List imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      _sendMessageCommon(base64Image, isImage: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seu Chat: ${widget.name}',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: _pickAndSendImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: _messages,
              user: me,
              showUserAvatars: true,
              showUserNames: true,
              onSendPressed: _handleSendPressed,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image, color: Colors.deepPurple),
                  onPressed: _pickAndSendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Digite uma mensagem...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        _sendMessageCommon(text);
                        _messageController.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessageCommon(_messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    socket.close();
    super.dispose();
  }
}