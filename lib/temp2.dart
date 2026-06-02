import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //mainAxisAlignment: MainAxisAlignment.spaceAround,
      body: Column(
        children: [
          SizedBox(height: 100),
          const ColoredBox(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            color: Colors.blue,
            child: SizedBox(width: double.infinity, height: 110),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
