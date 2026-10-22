//PrimeGo app - Perodua integrated mobility
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; //  Correct path
import 'package:flutter_native_certs/flutter_native_certs.dart';
import 'package:freerasp/freerasp.dart'; // Imported for Application Integrity Verification
import 'package:test_1/booking/bkg_detailList_region.dart';
import 'package:test_1/booking/booking_detailList_model.dart';
import 'package:test_1/booking/booking_detailList_model_variant.dart';
import 'package:test_1/booking/booking_detailList_variant.dart';
import 'package:test_1/booking/booking_functionList.dart';
import 'package:test_1/login/login2.dart';
import 'package:test_1/registration/reg_detailList_model_variant.dart';
import 'login/login.dart';
import 'homePage.dart';
import 'global.dart';
import 'registration/reg_functionList.dart';
import 'registration/reg_dashboard.dart';
import 'registration/reg_detailList_region.dart';
import 'registration/reg_detailList_model.dart';

// import 'registration/reg_dashboard_unconnected_stls.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Application Integrity Verification (freeRASP)
  final config = TalsecConfig(
    androidConfig: AndroidConfig(
      packageName: "com.primego.mobile",
      // Enter your Base64 encoded SHA256 signing hash below
      signingCertHashes: ["CH/oGy2PCtI4FJF0jyx6Aqj8fHBfCTeNcpnFI854mmQ="],
    ),
    watcherMail: "firdaus.rashid@perodua.com.my",
    isProd: true,
    // isProd: false, // when extract, please set to true
  );

  // 2. Bind background security warning callbacks via verified ThreatCallback format
  final callback = ThreatCallback(
    onAppIntegrity: () =>
        _handleSecurityTamper("Application integrity altered"),
    onHooks: () => _handleSecurityTamper("Hooking framework active"),
    onDebug: () {
      debugPrint(
        "SECURITY WARNING: Debugger hook caught. Terminating session...",
      );
      exit(0); // Safely shut down application process
    },
    onDeviceBinding: () => _handleSecurityTamper("Device binding broken"),

    // Required empty parameter profiles to complete ThreatCallback class specifications
    onPrivilegedAccess: () => _handleSecurityTamper("Jailbreak/Root detected"),
    onSimulator: () => _handleSecurityTamper("Simulator execution blocked"),
    onUnofficialStore: () =>
        debugPrint("Installed from unofficial store channel"),
    // onObfuscationIssues: () => debugPrint("Obfuscation verification warning"),
    // above commented for No anti-instrumentation protection detected. and new line added below.
    onObfuscationIssues: () => _handleSecurityTamper(
      "Anti-tamper / Obfuscation baseline verification failed",
    ),
    onDeviceID: () => debugPrint("Device fingerprint mismatch tracking"),
    onPasscode: () =>
        debugPrint("Device device lock screen pattern unprotected"),
    onSecureHardwareNotAvailable: () =>
        debugPrint("Hardware cryptographic vault isolated"),
  );

  // 3. Attach security listeners and ignite the runtime engine
  Talsec.instance.attachListener(callback);

  try {
    await Talsec.instance.start(config);
  } catch (e) {
    debugPrint('Failed to initialize freeRASP shield: ${e.toString()}');
  }

  try {
    await FlutterNativeCerts.instance.initialize();
  } on PlatformException catch (e) {
    debugPrint(
      'Failed to initialize FlutterNativeCerts plugin: ${e.toString()}',
    );
  }

  initializeGlobalDate();
  runApp(MyApp());
}

// 4. Force termination callback function on compromised devices
void _handleSecurityTamper(String warning) {
  debugPrint("SECURITY ACTION ENFORCED: $warning");
  exit(0);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: CleanLoginScreen(),
      // initialRoute: '/loginscreen',
      initialRoute: '/loginscreenTest',
      routes: {
        '/loginscreen': (context) => const CleanLoginScreen(),
        '/loginscreenTest': (context) => const PeroduaLoginPage(),
        '/homepage': (context) => const HomePage(),
        // Registration
        '/detailpage': (context) => const RegistrationAppWrapper(),
        // '/registrationpage_test': (context) => const RegistrationAppWrapper2(),
        // '/detailpage2': (context) => const DetailPage(title: 'Function List'),
        '/detailpage2': (context) => const DetailPage(),
        // '/detaillist': (context) => DetailListRegion(title: 'Detail List - Yearly target'),
        '/detaillist': (context) => DetailListRegion(),
        '/detaillistModel': (context) => DetailListModel(),
        '/detaillistVariant': (context) => DetailListVariant(),
        // Booking
        '/bkgfunctionList': (context) => const BkgFunctionListPage(),
        '/bkgdetaillist': (context) => DetailListRegionBkg(),
        '/bkgdetaillistModel': (context) => DetailListModelBkg(),
        '/bkgdetaillistVariant': (context) => DetailListVariantBkg(),
        '/bkgdetaillistVariantAll': (context) => DetailListVariantBkgAll(),
      },
    );
  }
}
