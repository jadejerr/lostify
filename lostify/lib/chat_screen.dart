import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_screen.dart';
import 'report_screen.dart';

enum ChatIntent { none, lost, found }

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // 🔑 WIT.AI TOKEN
  static const String _witToken =
      'Bearer N5THBQ5VY73RXSCWIIHX7NG7EH5IWWIQ';

  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();

  final List<_ChatMessage> _messages = [];

  ChatIntent _intent = ChatIntent.none;
  bool _awaitingDescription = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _bot("Hello 👋 What can I help you with today?");
    _showIntentOptions();
  }

  void _bot(String text) {
    setState(() {
      _messages.add(_ChatMessage(text, false));
    });
  }

  void _user(String text) {
    setState(() {
      _messages.add(_ChatMessage(text, true));
    });
  }

  void _showIntentOptions() {
    _bot("Please choose one option below 👇");
  }

  // SELECT INTENT
  void _selectIntent(ChatIntent intent) {
    setState(() {
      _intent = intent;
      _awaitingDescription = true;
    });

    if (intent == ChatIntent.lost) {
      _bot("What item did you lose?");
    } else {
      _bot("What item did you find?");
    }
  }

  // WIT.AI
  Future<Map<String, String>> _extractEntities(String text) async {
    final url =
        Uri.parse('https://api.wit.ai/message?v=20240101&q=$text');

    final res = await http.get(
      url,
      headers: {'Authorization': _witToken},
    );

    final data = jsonDecode(res.body);
    debugPrint("RAW WIT RESPONSE: $data");

    final entities = <String, String>{};

    if (data['entities'] != null) {
      data['entities'].forEach((key, list) {
        if (list.isNotEmpty) {
          entities[key.split(':').first] = list[0]['value'];
        }
      });
    }

    return entities;
  }

  // SEND MESSAGE
  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _user(text);

    if (!_awaitingDescription) return;

    setState(() => _isTyping = true);

    final entities = await _extractEntities(text);

    setState(() => _isTyping = false);

    if (_intent == ChatIntent.lost) {
      _handleLostFlow(entities);
    } else {
      _handleFoundFlow(entities);
    }
  }

  // LOST ITEM FLOW
  Future<void> _handleLostFlow(Map<String, String> entities) async {
    final keyword =
        entities['item_type'] ?? entities['item_brand'] ?? entities['colour'];

    if (keyword == null) {
      _bot("Sorry, I couldn’t understand the item. Please describe again.");
      return;
    }

    _bot("Here are some potential matches for \"$keyword\":");

    final matches = await supabase
        .from('public_reports')
        .select()
        .eq('status', 'active')
        .eq('report_type', 'found')
        .or(
          'title.ilike.%$keyword%,brand.ilike.%$keyword%',
        )
        .limit(3);

    if (matches.isEmpty) {
      _bot("I couldn’t find any matches right now.");
    } else {
      setState(() {
        _messages.add(_ChatMessage(
          "",
          false,
          matches: List<Map<String, dynamic>>.from(matches),
        ));
      });
    }

    _bot("You can view all possible matches below 👇");

    setState(() {
      _messages.add(
        _ChatMessage(
          "",
          false,
          action: _ChatAction.viewMatches,
        ),
      );
    });

    _awaitingDescription = false;
  }

  // FOUND ITEM FLOW
  void _handleFoundFlow(Map<String, String> entities) {
    _bot("Thanks! Please confirm to submit this found item report.");

    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportScreen(
            prefillData: entities,
            forceFound: true,
            showBack: true,
          ),
        ),
      );
    });

    _awaitingDescription = false;
  }

  // RESET CHAT
  void _resetChat() {
    setState(() {
      _messages.clear();
      _intent = ChatIntent.none;
      _awaitingDescription = false;
    });

    _bot("Hello 👋 What can I help you with today?");
    _showIntentOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lostify Bot"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetChat,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._messages.map(_bubble),
                if (_intent == ChatIntent.none) _intentButtons(),
                if (_isTyping)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Bot is typing..."),
                  ),
              ],
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _intentButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _selectIntent(ChatIntent.lost),
          child: const Text("Report Lost Item"),
        ),
        const SizedBox(width: 7),
        ElevatedButton(
          onPressed: () => _selectIntent(ChatIntent.found),
          child: const Text("Report Found Item"),
        ),
      ],
    );
  }

  Widget _bubble(_ChatMessage msg) {
    if (msg.matches != null) {
      return Column(
        children: msg.matches!
            .map(
              (m) => Card(
                child: ListTile(
                  leading: m['image_url'] != null
                      ? Image.network(m['image_url'], width: 50)
                      : const Icon(Icons.image),
                  title: Text(m['title']),
                  subtitle: Text(m['brand'] ?? 'Unknown'),
                ),
              ),
            )
            .toList(),
      );
    }

    if (msg.action == _ChatAction.viewMatches) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NotificationScreen(showBack: true),
            ),
          );
        },
        child: const Text("View all match items"),
      );
    }

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.isMe ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: msg.isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  const InputDecoration(hintText: "Type a message..."),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _send,
          )
        ],
      ),
    );
  }
}

enum _ChatAction { viewMatches }

class _ChatMessage {
  final String text;
  final bool isMe;
  final List<Map<String, dynamic>>? matches;
  final _ChatAction? action;

  _ChatMessage(
    this.text,
    this.isMe, {
    this.matches,
    this.action,
  });
}
