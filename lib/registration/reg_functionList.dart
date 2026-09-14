import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_1/model/services/Api.dart';
// import 'reg_detailList.dart';
import 'reg_dashboard.dart';

class DetailPage extends StatefulWidget {
  final String? title;

  const DetailPage({super.key, this.title});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // 1. Move your state variables to the top so they are globally accessible in this class
  // String curr_month_MM = DateFormat('MM').format(DateTime.now());
  // String curr_month_Mmm = DateFormat('MMM').format(DateTime.now());
  // String curr_year_YYYY = DateFormat('yyyy').format(DateTime.now());
  String get curr_month_Mmm {
    int monthNumber = int.tryParse(Api.currMonth) ?? 1;
    int yearNumber = int.tryParse(Api.currYear) ?? 2025;
    return DateFormat('MMM').format(DateTime(yearNumber, monthNumber));
  }

  late Future<List<dynamic>> _apiRequestsFuture;

  @override
  void initState() {
    super.initState();
    // _apiRequestsFuture = Future.wait([
    //   Api().get_actMntReg(), // Index 0
    //   Api().get_tgtMntReg(), // Index 1
    //   Api().get_currDate(), // Index 2
    // ]);
    _fetchData();
  }

  // Helper method to fetch/refresh API data when the month or year changes
  void _fetchData() {
    _apiRequestsFuture = Future.wait([
      Api().get_actMntReg(),
      Api().get_tgtMntReg(),
      Api().get_currDate(),
    ]);
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
                // Update the state variables and refresh the futures!
                setState(() {
                  // curr_month_MM = selectedMonth.toString().padLeft(2, '0');
                  // curr_year_YYYY = selectedYear.toString();

                  // DateTime tempMMMDate = DateTime(selectedYear, selectedMonth);
                  // curr_month_Mmm = DateFormat('MMM').format(tempMMMDate);

                  Api.currMonth = selectedMonth.toString().padLeft(2, '0');
                  Api.currYear = selectedYear.toString();

                  // Re-fetch API data for the newly selected date
                  _fetchData();
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
        String regActual = '00,000';
        String regTarget = '00,000';
        int raw_regActual = 0;
        int raw_regTarget = 0;
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
              final rawValue = dataList[0]['total_reg_month'];

              raw_regActual = responses[0]['data'][0]['total_reg_month'] ?? 0;
              final parsedValue = int.tryParse(rawValue?.toString() ?? '') ?? 0;

              regActual = NumberFormat.decimalPattern().format(parsedValue);

              if (regActual == '0') {
                regActual = '00,000';
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
              final rawValue = dataList[0]['target_reg_month'];

              raw_regTarget = responses[1]['data'][0]['target_reg_month'] ?? 0;
              final parsedValue = int.tryParse(rawValue?.toString() ?? '') ?? 0;

              regTarget = NumberFormat.decimalPattern().format(parsedValue);

              if (regTarget == '0') {
                regTarget = '00,000';
              }
            }
          }

          if (regTarget != '00,000' && regActual != '00,000') {
            //raw_regActual = 30500;
            regPcntge = (raw_regActual * 100) ~/ raw_regTarget;
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
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
                  actual: regActual,
                  target: regTarget,
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
                            RegistrationAppWrapper(),
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

                /*// Over last month
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
        
                // Over last year
                _buildComparisonCard(
                  title: 'Over last year',
                  subtitle: 'May 2026 vs May 2025',
                  currentLabel: "May'26",
                  currentValue: '7,076',
                  previousLabel: "May'25",
                  previousValue: '21,540',
                  difference: '-14,464',
                  circleColor: const Color(0xFF81C784),
                ),*/
              ],
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
                            // fontSize: 18,
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
                // width: 130,
                // height: 130,
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
