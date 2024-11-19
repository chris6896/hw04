import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ChatScreen extends StatelessWidget {
  final String boardId;

  ChatScreen({required this.boardId});

  final messageController = TextEditingController();

  Future<void> sendMessage() async {
    if (messageController.text.isNotEmpty) {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final username = FirebaseAuth.instance.currentUser!.displayName ?? 'Anonymous';

      await FirebaseFirestore.instance
          .collection('message_boards')
          .doc(boardId)
          .collection('messages')
          .add({
        'message': messageController.text,
        'username': username,
        'timestamp': Timestamp.now(),
      });

      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('message_boards')
                  .doc(boardId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(
                      title: Text(message['username'] ?? 'Unknown'),
                      subtitle: Text(message['message']),
                      trailing: Text(
                        (message['timestamp'] as Timestamp).toDate().toString(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: 'Enter a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
