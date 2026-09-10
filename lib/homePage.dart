// ignore: file_names
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_1/model/services/Api.dart';
import 'registration/reg_functionList.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Declare a late variable to hold your future network requests
  late Future<List<dynamic>> _apiRequestsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future exactly ONCE when the page loads
    _apiRequestsFuture = Future.wait([
      Api().get_actMntReg(), // Index 0
      Api().get_tgtMntReg(), // Index 1
      Api().get_actYearReg(), // Index 2
      Api.get_tgtYearReg(), // Index 3
      //Api.get_actMntBook(), // Index 4
      //Api.get_tgtMntBook(), // Index 5
      Api().get_actMntBkg(), // Index 4
      Api().get_tgtMntBkg(), // Index 5
    ]);
  }

  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return FutureBuilder<List<dynamic>>(
      // Fire all your API requests at the same time in parallel
      future: _apiRequestsFuture,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        // 1. Perform error handling if error while connection to DB
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Cannot connect to server',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to connect to backend.',
                    style: TextStyle(color: Colors.grey[600]),
                    // textAlign: Center,
                  ),
                ],
              ),
            ),
          );
        }

        // 2. Show a single global loading indicator while fetching
        /*if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }*/
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            // color: Colors.white, // Sets the background color to white
            color: Theme.of(context).scaffoldBackgroundColor,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors
                    .amber, // Optional: Changes spinner color so it's visible on white
              ),
            ),
          );
        }

        // 3. Fallback default values if the APIs fail or are loading
        // Registration yearly
        String regActYearly = '00,000';
        String regTgtYearly = '00,000';
        String regPctgYearly = '00.0';
        String regRemaining = '0';
        int rawRegRemaining = 0;
        int rawRegActYearly = 0;
        int rawRegTgtYearly = 0;
        double rawRegPctgYearly = 0;
        int rawRegIndicatorYearly = 0;

        // Registration monthly
        String regMntActual = '00,000';
        String regMntTarget = '00,000';
        String regShortage = '00.0k';
        String regPctgText = 'N/A';
        Color reg_color = Colors.red;
        Color regShortageColor = Colors.grey;
        // Color regShortageColor = Colors.pink;
        // Color regShortageColor = Colors.blue;
        // Color regShortageColor = Colors.green;
        int rawRegactual = 0;
        int rawRegtarget = 0;
        int regPcntge = 0;
        int rawRegShortage = 0;
        // double regPcntge = 0.0;   // if need decimal

        // Booking monthly
        String bookMntActual = '00,000';
        String bookMntTarget = '00,000';
        String bookShortage = '00.0k';
        String bookPctgText = 'N/A';
        Color book_color = Colors.red;
        Color bookShortageColor = Colors.grey;
        int rawBookactual = 0;
        int rawBooktarget = 0;
        int bookPcntge = 0;
        int rawBookShortage = 0;

        // Service monthly
        String serviceMntActual = '000.0k';
        String serviceMntTarget = '000.0k';
        String serviceShortage = '00.0k';
        String servicePctgText = 'N/A';
        Color service_color = Colors.red;
        Color serviceShortageColor = Colors.grey;
        int rawServiceactual = 0;
        int rawServicetarget = 0;
        int servicePcntge = 0;
        int rawServiceShortage = 0;

        // Parts monthly
        String partsMntActual = '0.00m';
        String partsMntTarget = '0.00m';
        String partsShortage = '0.00m';
        String partsPctgText = 'N/A';
        Color parts_color = Colors.red;
        Color partsShortageColor = Colors.grey;
        int rawPartsactual = 0;
        int rawPartstarget = 0;
        int partsPcntge = 0;
        int rawPartsShortage = 0;

        // 4. Extract data cleanly if successful
        if (snapshot.hasData) {
          final List<dynamic> responses = snapshot.data!;

          // Registration monthly math logic START
          // Parse Registration Month Actual (Index 0)
          if (responses[0]?['success'] == true &&
              responses[0]['data'].isNotEmpty) {
            // declare dataField for registrations
            var dataField = responses[0]['data'];

            // declare list
            List<dynamic> dataList = [];

            // If the API return data as a String string, decode it. Otherwise, cast it and assign it to dataList
            if (dataField is String) {
              dataList = jsonDecode(dataField);
            } else if (dataField is List) {
              dataList = dataField;
            }

            // Ensure the list is not empty before accessing index 0
            if (dataList.isNotEmpty) {
              final rawValue = dataList[0]['total_reg_month'];
              final parsedValue = int.tryParse(rawValue?.toString() ?? '') ?? 0;

              regMntActual = NumberFormat.decimalPattern().format(parsedValue);

              if (regMntActual == '0') {
                regMntActual = '00,000';
              }
            }
          }

          // Parse Registration Month Target (Index 1)
          if (responses[1]?['success'] == true &&
              responses[1]['data'].isNotEmpty) {
            regMntTarget = NumberFormat.decimalPattern().format(
              responses[1]['data'][0]['target_reg_month'] ?? 0,
            );
            if (regMntTarget == '0') {
              regMntTarget = '00,000';
            }
          }

          if (regMntActual != '00,000' && regMntTarget != '00,000') {
            rawRegactual = responses[0]['data'][0]['total_reg_month'] ?? 0;
            rawRegtarget = responses[1]['data'][0]['target_reg_month'] ?? 0;

            // calculate percentage
            regPcntge = (rawRegactual * 100) ~/ rawRegtarget;

            if (regPcntge > 99) {
              reg_color = Colors.green;
            } else if (regPcntge > 70) {
              reg_color = Colors.blue;
            } else if (regPcntge > 50) {
              reg_color = Colors.yellow;
            } else if (regPcntge > 25) {
              reg_color = Colors.orange;
            } else {
              reg_color = Colors.red;
            }

            // calculate surplus/shortage
            rawRegShortage = rawRegactual - rawRegtarget;
            //rawRegShortage = 31398;
            if (rawRegShortage > 0) {
              regPctgText = 'Surplus';
              regShortageColor = Colors.blue;
              //regShortageColor = Colors.green;
              regShortage =
                  '+${NumberFormat.compact().format(rawRegShortage).toLowerCase()}';
            } else if (rawRegShortage < 0) {
              regPctgText = 'Shortage';
              regShortageColor = Colors.pink;
              regShortage =
                  '${NumberFormat.compact().format(rawRegShortage).toLowerCase()}';
            } else {
              regPctgText = 'Exact';
              regShortageColor = Colors.blue;
              regShortage = NumberFormat.compact()
                  .format(rawRegShortage)
                  .toLowerCase();
            }
          }
          // Registration monthly math logic END

          // Registration yearly math logic START
          // Parse Registration Year Actual (Index 2)
          if (responses[2]?['success'] == true &&
              responses[2]['data'].isNotEmpty) {
            regActYearly = NumberFormat.decimalPattern().format(
              responses[2]['data'][0]['total_reg_year'] ?? 0,
            );
            //regActYearly2 = NumberFormat.decimalPattern().format(3662);
            if (regActYearly == '0') {
              regActYearly = '00,000';
            }
          }

          // Parse Registration Year Actual (Index 3)
          if (responses[3]?['success'] == true &&
              responses[3]['data'].isNotEmpty) {
            regTgtYearly = NumberFormat.decimalPattern().format(
              responses[3]['data'][0]['target_reg_year'] ?? 0,
            );
            if (regTgtYearly == '0') {
              regTgtYearly = '00,000';
            }

            if (regActYearly != '00,000' && regTgtYearly != '00,000') {
              rawRegActYearly = responses[2]['data'][0]['total_reg_year'] ?? 0;
              rawRegTgtYearly = responses[3]['data'][0]['target_reg_year'] ?? 0;

              // calculate percentage
              rawRegPctgYearly = ((rawRegActYearly * 100) / rawRegTgtYearly)
                  .toDouble();
              regPctgYearly = rawRegPctgYearly.toStringAsFixed(1);

              // calculate remaining
              rawRegRemaining = rawRegTgtYearly - rawRegActYearly;
              print('remaining: $rawRegRemaining');
              regRemaining = NumberFormat.decimalPattern().format(
                rawRegRemaining,
              );
            }
          }
          // Registration yearly math logic END

          // Booking monthly math logic START
          // Parse Booking Month Actual (Index 3)
          if (responses[4]?['success'] == true &&
              responses[4]['data'].isNotEmpty) {
            bookMntActual = NumberFormat.decimalPattern().format(
              responses[4]['data'][0]['total_bkg_month'] ?? 0,
            );
            if (bookMntActual == '0') {
              bookMntActual = '00,000';
            }
          }

          // Parse Booking Month Target (Index 4)
          if (responses[5]?['success'] == true &&
              responses[5]['data'].isNotEmpty) {
            bookMntTarget = NumberFormat.decimalPattern().format(
              responses[5]['data'][0]['TARGET_BKG_MONTH'] ?? 1,
            );
            if (bookMntTarget == '0') {
              bookMntTarget = '00,000';
            }
          }

          if (bookMntActual != '00,000' && bookMntTarget != '00,000') {
            //
            rawBookactual = responses[4]['data'][0]['total_bkg_month'] ?? 0;
            rawBooktarget = responses[5]['data'][0]['TARGET_BKG_MONTH'] ?? 0;

            // calculate percentage
            bookPcntge = (rawBookactual * 100) ~/ rawBooktarget;

            if (bookPcntge > 99) {
              book_color = Colors.green;
            } else if (bookPcntge > 70) {
              book_color = Colors.blue;
            } else if (bookPcntge > 50) {
              book_color = Colors.yellow;
            } else if (bookPcntge > 25) {
              book_color = Colors.orange;
            } else {
              book_color = Colors.red;
            }

            rawBookShortage = rawBookactual - rawBooktarget;
            if (rawBookShortage > 0) {
              bookPctgText = 'Surplus';
              bookShortageColor = Colors.blue;
              //bookShortageColor = Colors.green;
              bookShortage =
                  '+${NumberFormat.compact().format(rawBookShortage).toLowerCase()}';
            } else if (rawBookShortage < 0) {
              bookPctgText = 'Shortage';
              bookShortageColor = Colors.pink;
              bookShortage =
                  '${NumberFormat.compact().format(rawBookShortage).toLowerCase()}';
            } else {
              bookPctgText = 'Exact';
              bookShortageColor = Colors.blue;
              bookShortage = NumberFormat.compact()
                  .format(rawBookShortage)
                  .toLowerCase();
            }
          }

          // Booking monthly math logic END
        }

        return Scaffold(
          key: _scaffoldKey, // <-- 1. Assign the key to your Scaffold her
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    // color: Colors.blue
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color.fromARGB(255, 37, 99, 243), // Your color
                        const Color.fromARGB(
                          255,
                          5,
                          14,
                          144,
                        ), // Deep indigo-purple
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Separates title from logout button
                    children: [
                      Text(
                        'PRIME GO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Logout button aligned inside the header
                      InkWell(
                        onTap: () {
                          Navigator.pop(context); // Closes the drawer
                          print("Logged out from drawer header");
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout,
                                color: const Color.fromARGB(255, 243, 84, 21),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Log Out',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 243, 84, 21),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    // 1. Close the drawer first
                    Navigator.pop(context);
                    // 2. Add your custom function action here
                    print("Home clicked");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text('Registration'),
                  onTap: () {
                    print("Registration module pressed");
                    Navigator.pushNamed(
                      context, // Uses the fresh localContext to trace routes safely
                      '/detailpage2',
                      arguments: {
                        'title': 'Registration',
                        'month': 'May',
                        'year': '2026',
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Booking'),
                  onTap: () {
                    print("Booking module pressed");
                    Navigator.pushNamed(
                      context, // Uses the fresh localContext to trace routes safely
                      '/bkgfunctionList',
                      arguments: {
                        'title': 'Booking',
                        'month': 'May',
                        'year': '2026',
                      },
                    );
                  },
                ),
                /*ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout (Inline)',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    print("Logged out from inline button");
                  },
                ),*/
                /*const Divider(height: 1), // Optional line separation
                SafeArea(
                  top:
                      false, // Prevents bottom screen notch issues on modern devices
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Closes the drawer
                      print("Logged out from drawer bottom");
                    },
                  ),
                ),*/
              ],
            ),
          ),
          body: SafeArea(
            child: Builder(
              builder: (BuildContext localContext) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          /*const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey,
                          ),*/
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Welcome',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Ahmad Firdaus Bin Abd Rashid',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.menu, size: 28),
                            onPressed: () {
                              // This opens the right-side drawer using the key
                              _scaffoldKey.currentState?.openEndDrawer();
                            },
                          ),
                        ],
                      ),
                      // const SizedBox(height: 24),
                      const SizedBox(height: 20),
                      // Main Registration Card 2
                      Container(
                        // padding: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color.fromARGB(
                                255,
                                37,
                                99,
                                243,
                              ), // Your color
                              const Color.fromARGB(
                                255,
                                5,
                                14,
                                144,
                              ), // Deep indigo-purple
                            ],
                          ),
                          //color: const Color.fromARGB(255, 97, 41, 207),s
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'REGISTRATION',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      'ACTUAL REGISTRATION',
                                      style: TextStyle(
                                        fontSize: 12,
                                        // color: Colors.grey,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      // '82,198',
                                      regActYearly,
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold,
                                        // color: Colors.black,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      // width: 90,
                                      // height: 90,
                                      width: 80,
                                      height: 80,
                                      child: CircularProgressIndicator(
                                        value: 0.1,
                                        strokeWidth: 8,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.green,
                                            ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$regPctgYearly%',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            // color: Colors.green,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'of $regTgtYearly',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.grey,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*Expanded(
                                  child: Text(
                                    // '82,198',
                                    regActYearly,
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.black,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),*/
                                const SizedBox(width: 16),
                                // Circular Progress
                                /*Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: CircularProgressIndicator(
                                        value: 0.9657,
                                        strokeWidth: 8,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.green,
                                            ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '96.6%',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            // color: Colors.green,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'of $regTgtYearly',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.grey,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),*/
                              ],
                            ),
                            //const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.arrow_upward,
                                  // color: Colors.green,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$regPctgYearly% of target achieved',
                                  style: TextStyle(
                                    // color: Colors.green,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: 0.966,
                                minHeight: 8,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color.fromARGB(255, 21, 212, 27),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                //_buildTargetInfo('TARGET', '360,000'),
                                _buildTargetInfo('TARGET', regTgtYearly),
                                const Spacer(),
                                _buildTargetInfo(
                                  'REMAINING',
                                  regRemaining,
                                  alignRight: true,
                                ),
                                /*_buildTargetInfo(
                                  'REMAINING',
                                  remainingTarget,
                                  alignRight: true,
                                ),*/
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Four Cards Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: [
                          _buildMetricCard(
                            icon: Icons.directions_car,
                            title: 'Registration',
                            //current: '7,076',
                            //target: '34,000',
                            current: regMntActual,
                            target: regMntTarget,
                            percentage: regPcntge,
                            //percentageColor: Colors.blue,
                            percentageColor: reg_color,
                            percentageText: regPctgText,
                            change: regShortage,
                            changeColor: regShortageColor,
                            onTap: () {
                              print("Registration module pressed");
                              Navigator.pushNamed(
                                localContext, // Uses the fresh localContext to trace routes safely
                                '/detailpage2',
                                arguments: {
                                  'title': 'Registration',
                                  'month': 'May',
                                  'year': '2026',
                                },
                              );
                            },
                          ),
                          _buildMetricCard(
                            icon: Icons.person,
                            title: 'Booking',
                            current: bookMntActual,
                            target: bookMntTarget,
                            percentage: bookPcntge,
                            percentageColor: book_color,
                            percentageText: bookPctgText,
                            // change: '+0.0k',
                            change: bookShortage,
                            changeColor: bookShortageColor,
                            onTap: () {
                              print("Booking module pressed");
                              Navigator.pushNamed(
                                localContext, // Uses the fresh localContext to trace routes safely
                                '/bkgfunctionList',
                                arguments: {
                                  'title': 'Booking',
                                  'month': 'May',
                                  'year': '2026',
                                },
                              );
                            },
                          ),
                          _buildMetricCard(
                            icon: Icons.build,
                            title: 'Service',
                            current: serviceMntActual,
                            target: serviceMntTarget,
                            percentage: servicePcntge,
                            percentageColor: service_color,
                            percentageText: servicePctgText,
                            change: serviceShortage,
                            changeColor: serviceShortageColor,
                          ),
                          _buildMetricCard(
                            icon: Icons.handyman,
                            title: 'Parts',
                            current: partsMntActual,
                            target: partsMntTarget,
                            percentage: partsPcntge,
                            percentageColor: parts_color,
                            percentageText: partsPctgText,
                            change: partsShortage,
                            changeColor: partsShortageColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Bottom Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBottomIcon(
                            Icons.directions_car,
                            'POV',
                            Colors.blue,
                          ),
                          _buildBottomIcon(
                            Icons.shield,
                            'Insurance',
                            Colors.indigo,
                          ),
                          _buildBottomIcon(
                            Icons.settings,
                            'GearUp',
                            Colors.deepPurple,
                          ),
                          _buildBottomIcon(
                            Icons.factory,
                            'Production',
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTargetInfo(
    String label,
    String value, {
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            //color: Colors.grey
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String current,
    required String target,
    required int percentage,
    required Color percentageColor,
    required String percentageText,
    required String change,
    required Color changeColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      /*onTap: () {
        print('Container clicked!');
      },*/
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              // ignore: duplicate_ignore
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // color: Colors.grey[100],
                    // color: Colors.tealAccent[100],
                    color: (title == 'Registration' || title == 'Booking')
                        ? Colors.tealAccent[100]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // child: Icon(icon, size: 24),
                  child: Icon(icon, size: 18),
                ),
                //const Spacer(),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            //const SizedBox(height: 12),
            /*Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),*/
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  current,
                  style: const TextStyle(
                    // fontSize: 22,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ' / ',
                  // style: TextStyle(fontSize: 16, color: Colors.grey),
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  target,
                  // style: const TextStyle(fontSize: 16, color: Colors.grey),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Circular Progress
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      // width: 68,
                      // height: 68,
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentageColor,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: percentageColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                if (change.isNotEmpty)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          change,
                          style: TextStyle(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                            // fontSize: 13,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        percentageText,
                        style: TextStyle(
                          //fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: changeColor,
                          // color: percentageColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            /*const SizedBox(height: 15),
            // Change indicator
            if (change.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2.5),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
