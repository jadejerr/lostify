import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'), // Bot Avatar
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Chat Bot", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Happily Help You", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Center(child: Text("Nov 30, 2025, 9:41 AM", style: TextStyle(color: Colors.grey, fontSize: 12))),
                const SizedBox(height: 20),

                _buildMessage(isMe: false, text: "Welcome to Lostify. How can I assist you?"),
                _buildMessage(isMe: true, text: "Hello May I know how to report lost item?"),
                _buildMessage(isMe: false, text: "Cool", isShort: true),
                _buildMessage(isMe: false, text: "To report a lost item, type: 'I lost my..."),
                _buildMessage(isMe: true, text: "I lost my umbrella that is in blue and red stripes color."),
                _buildMessage(isMe: true, text: "Boom!", isShort: true),
                _buildMessage(isMe: false, text: "I found a match with your describtion."),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: NetworkImage('https://umbrellabeach.com.au/cdn/shop/files/upf50-carnivale-240cm-navy-blue-and-red5192484-732379_900x.jpg?v=1722310787'),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                ),
                
                _buildMessage(isMe: false, text: "Is this yours?"),
                _buildMessage(isMe: false, text: "If you need help again, I'm always here."),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200))
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.mic_none, color: Colors.grey), onPressed: () {}),
                IconButton(icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey), onPressed: () {}),
                IconButton(icon: const Icon(Icons.image_outlined, color: Colors.grey), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage({required bool isMe, required String text, bool isShort = false}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: isShort ? 100 : 250), // Adjust width based on content
        decoration: BoxDecoration(
          color: isMe ? Colors.black : Colors.grey.shade200, // User = Black, Bot = Grey
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}