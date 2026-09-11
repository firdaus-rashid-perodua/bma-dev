import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_1/model/services/Api.dart';

class PeroduaLoginPage extends StatefulWidget {
  const PeroduaLoginPage({super.key});

  @override
  State<PeroduaLoginPage> createState() => _PeroduaLoginPageState();
}

class _PeroduaLoginPageState extends State<PeroduaLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Instantly trigger loading to disable button double-clicks
    setState(() => _isLoading = true);

    // TODO: Implement your actual login logic here
    await Future.delayed(const Duration(seconds: 1));

    try {
      final result = await Api.loginUser(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      // Prevent calling setState if user closed the screen during network load
      if (!mounted) return;
      //setState(() => _isLoading = false);

      // Handle the API result mapping
      if (result['success'] == true) {
        // Clear input text fields upon success
        _usernameController.clear();
        _passwordController.clear();

        // Navigate to your main dashboard page
        Navigator.pushReplacementNamed(context, '/homepage');
      } else {
        // Show validation or LDAP credentials error message from Node.js
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Invalid credentials'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // Handle completely unexpected app connection drops safely
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      // THIS SCRIPT ALWAYS RUNS. Whether it succeeded or failed,
      // it turns off the loading spinner so you can click it a 2nd time.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely retrieve MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            /*decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF0F7FF), Color(0xFFE8F4FF), Colors.white],
              ),
            ),*/
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/login_bg.png',
                ), // Or your preferred background asset path
                fit: BoxFit
                    .cover, // Makes sure the image stretches to fill the entire screen
              ),
            ),
          ),

          // Decorative elements
          Positioned(
            top: size.height * 0.12,
            right: -20,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.bar_chart_rounded,
                size: 180,
                color: Colors.blue.shade300,
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.25,
            left: -30,
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 160,
                color: Colors.blue.shade400,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  /*const SizedBox(height: 20),
                  Image.network(
                    'https://www.perodua.com.my/assets/images/logo/perodua-logo.png',
                    height: 48,
                    errorBuilder: (_, __, ___) => const Text(
                      'PERODUA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066B3),
                      ),
                    ),
                  ),*/
                  const SizedBox(height: 60),
                  Image.asset(
                    'assets/p2_logo_words.png',
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'PERODUA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066B3),
                      ),
                    ),
                  ),
                  //const SizedBox(height: 8),
                  /*Text(
                    'Prime Go',
                    style: GoogleFonts.poppins(
                      fontSize: 55,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0066B3),
                      height: 1.1,
                    ),
                  ),*/
                  Image.asset(
                    'assets/primego_trend_words.png',
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'PERODUA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066B3),
                      ),
                    ),
                  ),
                  /*const SizedBox(height: 15),
                  Text(
                    'OUTLET MONITORIZATION',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Monitoring every outlet target\nand achievement, in real time.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),*/
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      // width: double.infinity,
                      width: MediaQuery.of(context).size.width * 0.85,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: Colors.grey,
                              ),
                              hintText: 'Username',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              ),
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ),
                          /*Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.blue.shade700),
                              ),
                            ),
                          ),*/
                          // const SizedBox(height: 8),
                          const SizedBox(height: 25),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003087),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
