import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotWidget extends StatefulWidget {
  @override
  _ChatbotWidgetState createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  Future<void> sendMessage(String message) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/chatbot/'),  // Cambia la URL si es necesario
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'input': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _response = data['response'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load chatbot response');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _response = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter your message',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              sendMessage(_controller.text);
            }
          },
          child: _isLoading ? CircularProgressIndicator() : Text('Send'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _response.isNotEmpty ? 'Bot: $_response' : 'Awaiting response...',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
