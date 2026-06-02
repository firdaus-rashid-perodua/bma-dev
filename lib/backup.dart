import 'package:flutter/material.dart';
import 'main2.dart';
import 'detailPage.dart';

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
      home: const RegistrationScreen(),
    );
  }
}

// Changed to StatefulWidget
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String _lastClicked = "Nothing clicked yet";
  int _clickCount = 0;

  void _handleCardTap(String cardName) {
    setState(() {
      _lastClicked = cardName;
      _clickCount++;
    });

    // Print to console (Debug)
    print('✅ Card Clicked: $cardName | Total clicks: $_clickCount');

    // Navigate to detail page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      //MaterialPageRoute(builder: (context) => DetailPage(title: cardName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            print('back button pressed');
          },
        ),
        title: const Text(
          'REGISTRATION',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Indicator
            /*Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Last clicked: $_lastClicked\nTotal taps: $_clickCount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),*/

            // Yearly Target
            _buildTargetCard(
              iconColor: const Color(0xFF4CAF50),
              title: 'Yearly target',
              subtitle: '2026',
              actual: '82,198',
              target: '360,000',
              percentage: 22,
              circleColor: const Color(0xFFCDDC39),
              onTap: () => _handleCardTap('Yearly Target'),
            ),
            const SizedBox(height: 16),

            // Monthly Target
            _buildTargetCard(
              iconColor: const Color(0xFF4CAF50),
              title: 'Monthly target',
              subtitle: 'May 2026',
              actual: '7,076',
              target: '34,000',
              percentage: 34,
              circleColor: const Color(0xFF26A69A),
              onTap: () => _handleCardTap('Monthly Target'),
            ),
            const SizedBox(height: 16),

            // Comparison Cards (not clickable for now)
            _buildComparisonCard(
              title: 'Over last month',
              subtitle: 'May 2026 vs May 2025',
              currentLabel: "May'26",
              currentValue: '7,076',
              previousLabel: "Apr'26",
              previousValue: '26,127',
              difference: '-19,051',
              circleColor: const Color(0xFF81D4FA),
            ),
            const SizedBox(height: 16),

            _buildComparisonCard(
              title: 'Over last year',
              subtitle: 'May 2026 vs May 2025',
              currentLabel: "May'26",
              currentValue: '7,076',
              previousLabel: "May'25",
              previousValue: '21,540',
              difference: '-14,464',
              circleColor: const Color(0xFF80CBC4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetCard({
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actual,
    required String target,
    required int percentage,
    required Color circleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.grid_view,
                            color: iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('actual : $actual'),
                    Text('target : $target'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildPercentageCircle(percentage, circleColor),
            ],
          ),
        ),
      ),
    );
  }

  // Keep your existing helper methods
  Widget _buildComparisonCard({
    required String title,
    required String subtitle,
    required String currentLabel,
    required String currentValue,
    required String previousLabel,
    required String previousValue,
    required String difference,
    required Color circleColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.grid_view,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 16),
                  Text('$currentLabel : $currentValue'),
                  Text('$previousLabel : $previousValue'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildDifferenceCircle(difference, circleColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageCircle(int percentage, Color color) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '$percentage%',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceCircle(String difference, Color color) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 12),
            ),
          ),
          Text(
            difference,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
