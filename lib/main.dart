//PrimeGo app - Perodua integrated mobility
import 'package:flutter/material.dart';
import 'package:test_1/booking/bkg_detailList_region.dart';
import 'package:test_1/booking/booking_detailList_model.dart';
import 'package:test_1/booking/booking_detailList_model_variant.dart';
import 'package:test_1/booking/booking_functionList.dart';
import 'package:test_1/login/login2.dart';
import 'package:test_1/registration/reg_detailList_model_variant.dart';
import 'login/login.dart';
import 'homePage.dart';
import 'registration/reg_functionList.dart';
import 'registration/reg_dashboard.dart';
import 'registration/reg_detailList_region.dart';
import 'registration/reg_detailList_model.dart';

// import 'registration/reg_dashboard_unconnected_stls.dart';

void main() {
  runApp(MyApp());
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
      },
    );
  }
}
