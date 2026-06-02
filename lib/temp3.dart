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
      body: Container(
        decoration: BoxDecoration(
          //color: Color(0xFF1F1F1F)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            /*Container(
              height: 80,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 145, 114, 114),
              ),
              child: Stack(
                alignment: Alignment.center, // Aligns unpositioned children
                children: [
                  // Bottom layer: A baseline box or image
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.blue,
                  ),
                  // Middle layer: Aligned via Stack alignment property
                  Container(width: 100, height: 100, color: Colors.red),
                  // Top layer: Pinned to a specific coordinate
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Icon(Icons.star, color: Colors.white),
                  ),
                ],
              ),
            ),*/
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Expanded(child: Container(color: Colors.blue)),
                      Expanded(child: Container(color: Colors.red)),
                    ],
                  ),
                  Positioned(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 40,
                        color: Colors.amberAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 100,
              padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Perodua',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 145, 114, 114),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      //color: Color.fromARGB(255, 159, 109, 109),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(80),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              width: double.infinity,
              //height: 2000,
              decoration: BoxDecoration(color: Color(0xFFF8F9FA)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize:
                          24.0, // Increase this number to make the text larger
                      //fontWeight: FontWeight.bold, // Optional: makes it bold
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Name: '),
                  SizedBox(height: 20),
                  Text('Password: '),
                  SizedBox(height: 20),
                  Text('Log In: '),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
