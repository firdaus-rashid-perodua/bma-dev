import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CleanLoginScreen(),
    );
  }
}

class CleanLoginScreen extends StatelessWidget {
  const CleanLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetches the exact total width and height of the phone glass screen
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: SizedBox(
        // Forces this root layout to completely occupy 100% of the screen space
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            // LAYER 1: Full Screen Canvas Background (Light Grey base)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFE3F2FD),
            ),

            // LAYER 2: The Dark Header Block (Middle band section)
            Positioned(
              top: screenHeight * 0.18, // Pushes it down past the top text zone
              left: 0,
              right: 0,
              height: screenHeight * 0.22, // Fills out the middle dark band
              child: Container(color: const Color(0xFF2A2A2A)),
            ),

            // LAYER 3: Typography Section ("Perodua house")
            Positioned(
              top:
                  screenHeight *
                  0.10, // Safely positioned away from screen top edge
              left: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perodua',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2A2A), // Dark text on light background
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ), // Proportionate spacing
                  const Text(
                    'house',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.white, // White text over the dark band
                    ),
                  ),
                ],
              ),
            ),

            // LAYER 4: The Floating Circular Profile/Brand Image
            Positioned(
              right: 32,
              top:
                  screenHeight *
                  0.09, // Aligns horizontally across the color boundary split
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: CircleAvatar(
                    backgroundColor: Color(0xFFEBEBEB),
                    // Optional: swap with network image or local assets later
                    child: Icon(
                      Icons.directions_car,
                      size: 40,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                ),
              ),
            ),

            // LAYER 5: The White Login Form Sheet (Covers remaining bottom space fully)
            Positioned(
              top:
                  screenHeight *
                  0.36, // Starts right where the dark background needs to transition
              left: 0,
              right: 0,
              bottom:
                  0, // <--- Forces it to stretch down to touch the absolute bottom edge
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(
                      48.0,
                    ), // Clean sweeping corner curve
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 40.0,
                    right: 40.0,
                    top: 44.0,
                    // Keeps content safely viewable above device bottom system pills/bars
                    bottom: MediaQuery.paddingOf(context).bottom + 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Field Input
                      _buildInputField(
                        label: "Email",
                        hint: "user@perodua.com.my",
                      ),
                      const SizedBox(height: 20),

                      // Password Field Input
                      _buildInputField(
                        label: "Password",
                        hint: "••••••••",
                        isObscure: true,
                      ),
                      const SizedBox(height: 16),

                      // Navigation Text Options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot password ?',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Create an account',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Execution Sign In Button
                      Center(
                        child: SizedBox(
                          width: 180,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A2A2A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Component Helper function to draw identical clean entry text boxes
  Widget _buildInputField({
    required String label,
    required String hint,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2.0, bottom: 6.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            filled: true,
            fillColor: const Color(
              0xFFDFDFDF,
            ), // Matches inner background tint depth
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black26),
            ),
          ),
        ),
      ],
    );
  }
}
