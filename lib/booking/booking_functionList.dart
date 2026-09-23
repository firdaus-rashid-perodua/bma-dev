import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_1/model/services/Api.dart';
// import 'reg_detailList.dart';
import 'booking_dashboard.dart';

class BkgFunctionListPage extends StatefulWidget {
  final String? title;

  const BkgFunctionListPage({super.key, this.title});

  @override
  State<BkgFunctionListPage> createState() => _BkgFunctionListPageState();
}

class _BkgFunctionListPageState extends State<BkgFunctionListPage> {
  late Future<List<dynamic>> _apiRequestsFuture;

  @override
  void initState() {
    super.initState();
    _loadData(); // 1 reload
  }

  //2 reload
  void _loadData() {
    _apiRequestsFuture = Future.wait([
      Api().get_actMntBkg(), // Index 0
      Api().get_tgtMntBkg(), // Index 1
      Api().get_currDate(), // Index 2
    ]);
  }

  //3 reload
  Future<void> _handleRefresh() async {
    setState(() {
      _loadData(); // Triggers a reload of your data blueprints
    });
    // Waits for the new future bundle to finish completing before hiding the spinner
    await _apiRequestsFuture;
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    int selectedYear = int.tryParse(Api.currYear) ?? DateTime.now().year;
    int selectedMonth = int.tryParse(Api.currMonth) ?? DateTime.now().month;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Month & Year'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return SizedBox(
                width: 300,
                height: 300,
                child: Column(
                  children: [
                    DropdownButton<int>(
                      value: selectedYear,
                      items:
                          List.generate(
                                10,
                                (index) => DateTime.now().year - 5 + index,
                              )
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text("$year"),
                                ),
                              )
                              .toList(),
                      onChanged: (year) {
                        if (year != null) {
                          setDialogState(() => selectedYear = year);
                        }
                      },
                    ),
                    const Divider(),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.5,
                            ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final monthLabels = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec',
                          ];
                          final isSelected = selectedMonth == index + 1;
                          return TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Theme.of(context).primaryColor
                                  : null,
                              foregroundColor: isSelected ? Colors.white : null,
                            ),
                            onPressed: () {
                              setDialogState(() => selectedMonth = index + 1);
                            },
                            child: Text(monthLabels[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the global static state variables!
                setState(() {
                  Api.currMonth = selectedMonth.toString().padLeft(2, '0');
                  Api.currYear = selectedYear.toString();

                  // Re-fetch API data for the newly selected date
                  _loadData();
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  // ==========================================

  Widget build(BuildContext context) {
    // 1. Extract the arguments map safely
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // 2. Fallback values if arguments or keys are null
    final String displayTitle =
        args?['title'] ?? widget.title ?? 'Function List';
    final String displayMonth = args?['month'] ?? '[month]';
    final String displayYear = args?['year'] ?? '[year]';

    return FutureBuilder<List<dynamic>>(
      future: _apiRequestsFuture,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(
                    context,
                  ).size.height, // Forces it to take up the full screen height
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Cannot connect to server',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
        String bkgActual = '00,000';
        String bkgTarget = '00,000';
        int raw_bkgActual = 0;
        int raw_bkgTarget = 0;
        // double regPcntge = 0.0;
        int regPcntge = 0;
        Color? reg_color = Colors.red;

        String curr_month_MM = '01';
        String curr_month_Mmm = 'Jan';
        String curr_year_YYYY = '1999';

        // 4. Start to store data
        if (snapshot.hasData) {
          final List<dynamic> responses = snapshot.data!;

          if (responses[2]?['success'] == true &&
              responses[2]['data'].isNotEmpty) {
            var dataField = responses[0]['data'];
            List<dynamic> dataList = [];

            if (dataField is String) {
              dataList = jsonDecode(dataField);
            } else if (dataField is List) {
              dataList = dataField;
            }

            curr_month_MM = responses[2]['data'][0]['curr_month'] ?? 0;
            curr_year_YYYY = responses[2]['data'][0]['curr_year'] ?? 0;

            int monthNumber = int.parse(curr_month_MM);
            int yearNumber = int.parse(curr_year_YYYY);
            DateTime tempMMMDate = DateTime(yearNumber, monthNumber);

            curr_month_Mmm = DateFormat('MMM').format(tempMMMDate);

            print("Current month MM: $curr_month_MM");
            print("Current month MMM: $curr_month_Mmm");
            print("Current year YYYY: $curr_year_YYYY");
          }

          if (responses[0]?['success'] == true &&
              responses[0]['data'].isNotEmpty) {
            //
            var dataField = responses[0]['data'];
            List<dynamic> dataList = [];

            if (dataField is String) {
              dataList = jsonDecode(dataField);
            } else if (dataField is List) {
              dataList = dataField;
            }

            if (dataList.isNotEmpty) {
              final rawValue = dataList[0]['total_bkg_month'];

              raw_bkgActual = responses[0]['data'][0]['total_bkg_month'] ?? 0;
              final parsedValue = int.tryParse(rawValue?.toString() ?? '') ?? 0;

              bkgActual = NumberFormat.decimalPattern().format(parsedValue);

              if (bkgActual == '0') {
                bkgActual = '00,000';
              }
            }
          }

          if (responses[1]?['success'] == true &&
              responses[1]['data'].isNotEmpty) {
            //
            var dataField = responses[1]['data'];
            List<dynamic> dataList = [];

            if (dataField is String) {
              dataList = jsonDecode(dataField);
            } else if (dataField is List) {
              dataList = dataField;
            }

            if (dataList.isNotEmpty) {
              final rawValue = dataList[0]['TARGET_BKG_MONTH'];

              raw_bkgTarget = responses[1]['data'][0]['TARGET_BKG_MONTH'] ?? 0;
              final parsedValue = int.tryParse(rawValue?.toString() ?? '') ?? 0;

              bkgTarget = NumberFormat.decimalPattern().format(parsedValue);

              if (bkgTarget == '0') {
                bkgTarget = '00,000';
              }
            }
          }

          if (bkgTarget != '00,000' && bkgActual != '00,000') {
            //raw_bkgActual = 30500;
            regPcntge = (raw_bkgActual * 100) ~/ raw_bkgTarget;
          }
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
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            /*leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {},
            ),*/
            title: Text(
              displayTitle,
              //'$title',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    // Programmatically opens the drawer from the right
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ],
          ),
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
                          // Navigator.pop(context); // Closes the drawer
                          // print("Logged out from drawer header");
                          Navigator.pushNamed(context, '/loginscreenTest');
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
                /*ListTile(
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
                    Navigator.pop(context);
                    print("Settings clicked");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Booking'),
                  onTap: () {
                    Navigator.pop(context);
                    print("Settings clicked");
                  },
                ),*/
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Text(
                      //   // '$displayMonth $displayYear',
                      //   '$curr_month_Mmm $curr_year_YYYY',
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      // const SizedBox(width: 8),
                      // const Icon(Icons.access_time, color: Colors.grey),
                      InkWell(
                        onTap: () => _selectMonthYear(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              // '$displayMonth $displayYear',
                              '$curr_month_Mmm $curr_year_YYYY',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.access_time, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Yearly Target
                  /*_buildTargetCard(
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Yearly target',
                    subtitle: '2026',
                    actual: '82,198',
                    target: '360,000',
                    percentage: '22%',
                    circleColor: const Color(0xFF9CCC65),
                    circleTextColor: Colors.black,
                    onTap: () {
                      Navigator.push(
                        context,
                        //MaterialPageRoute(builder: (context) => HomePage()),
                        MaterialPageRoute(
                          builder: (context) =>
                              // DetailList(title: '$title - Yearly target'),
                              RegistrationsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  */

                  // Monthly Target
                  _buildTargetCard(
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Monthly target',
                    subtitle: '$curr_month_Mmm $curr_year_YYYY',
                    actual: bkgActual,
                    target: bkgTarget,
                    percentage: '$regPcntge%',
                    circleColor: reg_color,
                    circleTextColor: Colors.black,
                    onTap: () {
                      Navigator.push(
                        context,
                        //MaterialPageRoute(builder: (context) => HomePage()),
                        MaterialPageRoute(
                          builder: (context) =>
                              // DetailList(title: '$title - Monthly target'),
                              // RegistrationsScreen(),
                              BookingAppWrapper(),
                        ),
                      );
                      /*Navigator.pushNamed(
                                  localContext, // Uses the fresh localContext to trace routes safely
                                  '/detailpage2',
                                  arguments: {
                                    'title': 'Registration',
                                    'month': 'May',
                                    'year': '2026',
                                  },
                                );
                              },*/
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTargetCard({
    required Color iconColor,

    required String title,
    required String subtitle,
    required String actual,
    required String target,
    required String percentage,
    required Color circleColor,
    required Color circleTextColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.grid_view,
                            color: iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow('actual : ', actual),
                    const SizedBox(height: 6),
                    _buildStatRow('target : ', target),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Percentage Circle
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: circleColor, width: 10),
                ),
                child: Center(
                  child: Text(
                    percentage,
                    // '123%',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: circleTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.grid_view,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('$currentLabel : ', currentValue),
                  const SizedBox(height: 6),
                  _buildStatRow('$previousLabel : ', previousValue),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Difference Circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: circleColor, width: 10),
              ),
              child: Center(
                child: Text(
                  difference,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
