import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageBoardsScreen extends StatelessWidget {
  final Map<String, IconData> boardIcons = {
    'Games': Icons.games,
    'Business': Icons.business,
    'Public Health': Icons.health_and_safety,
    'Study': Icons.school,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Boards'),
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('message_boards')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No message boards available.'));
          }

          final boards = snapshot.data!.docs;

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: boards.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              var board = boards[index];
              String boardName = board['name'];
              
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: Icon(
                    boardIcons[boardName] ?? Icons.forum,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    boardName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(board['description'] ?? ''),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: board.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}