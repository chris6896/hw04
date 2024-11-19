import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'message_boards_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeMessageBoards();
  runApp(MyApp());
}

Future<void> initializeMessageBoards() async {
  final boards = ['Games', 'Business', 'Public Health', 'Study'];
  final firestore = FirebaseFirestore.instance;
  
  // Get existing boards
  final existingBoards = await firestore.collection('message_boards').get();
  final existingBoardNames = existingBoards.docs.map((doc) => doc['name'] as String).toList();

  // Add only boards that don't exist yet
  for (final board in boards) {
    if (!existingBoardNames.contains(board)) {
      await firestore.collection('message_boards').add({
        'name': board,
        'createdAt': Timestamp.now(),
        'description': 'Discussion board for ${board.toLowerCase()} related topics',
      });
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Board App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/boards': (context) => MessageBoardsScreen(),
        '/chat': (context) => ChatScreen(
              boardId: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/settings': (context) => SettingsScreen(),
        '/edit_profile': (context) => EditProfileScreen(),  
      },
    );
  }
}