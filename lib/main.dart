import 'package:flutter/material.dart';
import 'screens/contacts_page.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu Chat',
      home: const ContactsPage(),
    );
  }
}