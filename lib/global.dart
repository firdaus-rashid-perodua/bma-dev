// lib/global.dart

// This will store your global user data
String globalLoginId = '';
String globalUserName = '';
String globalUserEmail = '';

String aclRegistration = '';
String aclBooking = '';
String aclParts = '';
String aclService = '';

// Helper to check if someone is logged in
bool isUserLoggedIn = false;

//Real running date
// --- Global Date Variables ---
String globalCurrentMonth =
    ''; // Stores full name (e.g., 'September') or number
String globalCurrentYear = ''; // Stores year (e.g., '2026')

/// Call this function during app startup (e.g., in main.dart) to lock in the current time
void initializeGlobalDate() {
  final now = DateTime.now();

  // List to map integer month to full English name
  const monthNames = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
  ];

  globalCurrentMonth =
      monthNames[now.month - 1]; // now.month ranges from 1 to 12
  globalCurrentYear = now.year.toString();
}
