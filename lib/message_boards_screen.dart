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
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: Icon(Icons.person),
                  label: Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
          ),
        ],
      ),
    );
  }
}