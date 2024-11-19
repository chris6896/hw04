import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  Future<void> registerUser(BuildContext context) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user!.updateDisplayName(
        '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'user',
        'registrationDateTime': DateTime.now(),
      });

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Error'),
          content: Text(e.toString()),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'First Name')),
            TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'Last Name')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => registerUser(context), child: Text('Register')),
          ],
        ),
      ),
    );
  }
}
