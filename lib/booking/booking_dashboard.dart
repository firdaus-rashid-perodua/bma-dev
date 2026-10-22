// ignore: file_names
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:test_1/model/services/Api.dart';
import 'package:test_1/model/testRegionModel.dart';

// import 'package:oracledb/oracledb.dart';
// import 'detailList.dart';

class BookingAppWrapper extends StatelessWidget {
  const BookingAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DashboardData>(
      create: (context) => DashboardData(),
      // builder: (context, child) => BookingScreen(),
      child: BookingScreen(),
    );
  }
}

class DashboardData extends ChangeNotifier {
  bool isRegionView = true;

  // 1. Add fields to store your API data
  String regActual = '00,000';
  String regTarget = '00,000';

  // List<RegionModel> regionData = [];
  List<RegionModel> regionData = [
    RegionModel(
      title: 'REGION 1',
      percentage: '0%',
      color: Colors.green,
      actual: 'N/A',
      target: 'N/A',
      yoy: 'N/A MTD',
      yoyColor: Colors.green,
    ),
    RegionModel(
      title: 'REGION 2',
      percentage: '0%',
      color: Colors.green,
      actual: 'N/A',
      target: 'N/A',
      yoy: 'N/A MTD',
      yoyColor: Colors.green,
      //onTap: () { Navigator.pushNamed(context, '/registrationpage_test');}, //error context undefined
    ),
    RegionModel(
      title: 'REGION 3',
      percentage: '0%',
      color: Colors.green,
      actual: 'N/A',
      target: 'N/A',
      yoy: 'N/A MTD',
      yoyColor: Colors.green,
    ),
    RegionModel(
      title: 'REGION 4',
      percentage: '0%',
      color: Colors.green,
      actual: 'N/A',
      target: 'N/A',
      yoy: 'N/A MTD',
      yoyColor: Colors.green,
    ),
  ];

  List<RegionModel> modelData = [
    RegionModel(
      title: 'ATIVAx',
      percentage: '0%',
      color: Colors.blue,
      actual: 'N/A',
      target: 'N/A',
      yoy: 'N/A MTD',
      yoyColor: Colors.blue,
    ),
    RegionModel(
      title: 'ARUZ',
      percentage: '0%',
      color: Colors.orange,
      actual: 'N/A',
      target: 'N/A',
      yoy: 'N/A MTD',
      yoyColor: Colors.green,
    ),
    RegionModel(
      title: 'MYVI',
      percentage: '0%',
      color: Colors.green,
      actual: 'N/A',
      target: 'N/A',
      yoy: 'N/A MTD',
      yoyColor: Colors.green,
    ),
    RegionModel(
      title: 'TRAZ',
      percentage: '0%',
      color: Colors.red,
      actual: 'N/A',
      target: 'N/A',
      yoy: 'N/A MTD',
      yoyColor: Colors.red,
    ),
    RegionModel(
      title: 'AXIA',
      percentage: '0%',
      color: Colors.red,
      actual: 'N/A',
      target: 'N/A',
      yoy: 'N/A MTD',
      yoyColor: Colors.red,
    ),
  ];

  // Create a method to update the dynamic data from your database rows
  void updateCentral2Actual(
    String actualReg,
    String targetReg,
    String pctgReg,
  ) {
    // Find the item and update its actual string value
    if (regionData[1].actual != actualReg) {
      regionData[1] = RegionModel(
        routeType: 'REGION',
        title: 'TEST',
        percentage: pctgReg,
        color: regionData[1].color,
        actual: actualReg, // Sets your fresh database string!
        target: targetReg,
        yoy: regionData[1].yoy,
        yoyColor: regionData[1].yoyColor,
      );

      // Push the state update safely to the layout loop
      Future.microtask(() => notifyListeners());
    }
  }

  // Helper method to add commas to integers (e.g., 6099 -> "6,099")
  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    int numValue = value is int ? value : int.tryParse(value.toString()) ?? 0;
    return numValue.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
  }

  void updateRegionsFromData(List<dynamic> apiDataList) {
    // 1. Map the JSON rows into your temporary model structure
    final List<RegionModel> newModels = apiDataList.map((row) {
      // Read the new full name key we just created in your SQL query!
      String displayName =
          row['REGION_NAME']?.toString() ??
          row['REGION']?.toString() ??
          'REGION';
      String freshActual = _formatNumber(row['ACTUAL_BKG_COUNT']);
      String freshTarget = _formatNumber(row['TARGET_BKG_COUNT']);
      String freshPctg = '${row['BKG_PCTG_1'] ?? '0.0'}%';
      String region_Code = '${row['REGION'] ?? ''}';
      Color reg_color = Colors.grey;

      if (row['BKG_PCTG_1'] > 99.9) {
        reg_color = Colors.green;
      } else if (row['BKG_PCTG_1'] > 69.9) {
        reg_color = Colors.blue;
      } else if (row['BKG_PCTG_1'] > 49.9) {
        reg_color = Color(0xFFE6A100);
      } else if (row['BKG_PCTG_1'] > 24.9) {
        reg_color = Colors.orange;
      } else {
        reg_color = Colors.red;
      }

      if (row['TARGET_BKG_COUNT'] == 0) {
        reg_color = Colors.grey;
      }

      return RegionModel(
        routeType: 'REGION',
        title: displayName,
        regionCode: region_Code,
        percentage: freshPctg,
        actual: freshActual,
        target: freshTarget,
        color: reg_color,
        yoy: '0.0% MTD',
        yoyColor: Colors.blue,
        icon: Icons.business,
      );
    }).toList();

    // 2. BREAK THE LOOP: Check if the list actually changed before notifying
    if (regionData.length != newModels.length ||
        (regionData.isNotEmpty &&
            regionData.first.actual != newModels.first.actual)) {
      regionData = newModels;

      // Push the state update safely outside the current layout calculation phase
      Future.microtask(() => notifyListeners());
    }
  }

  void updateModelFromData(List<dynamic> apiDataList) {
    // 1. Map the JSON rows into your temporary model structure
    final List<RegionModel> newModels = apiDataList.map((row) {
      // Read the new full name key we just created in your SQL query!
      String displayName =
          row['Model']?.toString() ??
          // row['REGION']?.toString() ??
          'MODEL';
      String freshActual = _formatNumber(row['TOTAL']);
      // String freshActual = _formatNumber(row['ACTUAL_BKG_COUNT']);
      String freshTarget = _formatNumber(row['TARGET_BKG_COUNT']);
      String freshPctg = '${row['BKG_PCTG_1'] ?? '0.0'}%';
      Color bkg_modelColor = Colors.grey;

      final double pctg =
          double.tryParse(row['BKG_PCTG_1']?.toString() ?? '0') ?? 0.0;

      if (pctg >= 100.0) {
        bkg_modelColor = Colors.green; // Deep Emerald Green (Excellent)
      } else if (pctg >= 70.0) {
        bkg_modelColor = Colors.blue; // Dark Teal (On Track)
      } else if (pctg >= 50.0) {
        bkg_modelColor = Color(
          0xFFE6A100,
        ); // Deep Amber/Gold (Warning - readable on white)
      } else if (pctg >= 25.0) {
        bkg_modelColor = Colors.orange; // Burnt Orange (Low Performance)
      } else {
        bkg_modelColor = Colors.red; // Crimson Red (Critical)
      }

      if (row['TARGET_BKG_COUNT'] == 0) {
        bkg_modelColor = Colors.grey;
      }

      return RegionModel(
        routeType: 'MODEL',
        title: displayName,
        regionCode: null,
        percentage: freshPctg,
        actual: freshActual,
        target: freshTarget,
        color: bkg_modelColor,
        yoy: '0.0% MTD',
        yoyColor: Colors.blue,
        icon: Icons.directions_car,
      );
    }).toList();

    // 2. BREAK THE LOOP: Check if the list actually changed before notifying
    if (modelData.length != newModels.length ||
        (modelData.isNotEmpty &&
            modelData.first.actual != newModels.first.actual)) {
      modelData = newModels;

      // Push the state update safely outside the current layout calculation phase
      Future.microtask(() => notifyListeners());
    }
  }

  // Update this to accept both index 3 data (totals) and your maintenance model list data
  void updateModelFromData2(
    List<dynamic> fmrTotalsList,
    List<dynamic> maintenanceModelList,
    List<dynamic> targetModelList,
  ) {
    // 1. Create a quick lookup map for totals by FMR_ID: { "C10114": 7, "C10106": 52, ... }
    final Map<String, int> fmrTotalMap = {
      for (var row in fmrTotalsList)
        row['FMR_ID']?.toString() ?? '':
            int.tryParse(row['TOTAL']?.toString() ?? '0') ?? 0,
    };

    final Map<String, int> targetModelMap = {
      for (var row in targetModelList)
        row['MODEL']?.toString().toUpperCase() ?? '':
            int.tryParse(row['TOTAL']?.toString() ?? '0') ?? 0,
    };

    // 2. Group and Sum totals by vehicle MODEL
    final Map<String, int> modelAccumulator = {};

    for (var row in maintenanceModelList) {
      // print(row);
      String fmrId = row['FMR_ID']?.toString() ?? '';
      String modelName = row['MODEL']?.toString() ?? 'UNKNOWN';

      // Get the total amount for this FMR_ID (defaults to 0 if not found)
      int totalForFmr = fmrTotalMap[fmrId] ?? 0;

      // Accumulate the amount into the respective vehicle model group
      modelAccumulator.update(
        modelName,
        (existingTotal) => existingTotal + totalForFmr,
        ifAbsent: () => totalForFmr,
      );
    }

    // print(modelAccumulator);

    // 3. Convert the map entries to a list and SORT from highest to lowest total
    final sortedEntries =
        modelAccumulator.entries
            .where((entry) => entry.value > 0) // <-- THIS DROPS ZERO VALUES
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // 4. Map the aggregated model dictionary into your RegionModel list format for the UI cards
    final List<RegionModel> newModels = sortedEntries.map((entry) {
      String displayName = entry.key;
      int actualTotal = entry.value;

      // Fetch target for this model (defaults to 0 if not found)
      int targetTotal = targetModelMap[displayName] ?? 0;

      String freshActual = _formatNumber(actualTotal);
      String freshTarget = _formatNumber(targetTotal);

      // Calculate percentage: (Actual / Target) * 100
      double pctg = 0.0;
      if (targetTotal > 0) {
        pctg = (actualTotal / targetTotal) * 100.0;
      }
      String freshPctg = '${pctg.toStringAsFixed(1)}%';

      // Determine card color based on completion percentage
      Color bkg_modelColor = Colors.grey;
      if (targetTotal == 0) {
        bkg_modelColor = Colors.grey;
      } else if (pctg >= 100.0) {
        bkg_modelColor = Colors.green; // Excellent
      } else if (pctg >= 70.0) {
        bkg_modelColor = Colors.blue; // On Track
      } else if (pctg >= 50.0) {
        bkg_modelColor = Color(0xFFE6A100); // Warning / Amber
      } else if (pctg >= 25.0) {
        bkg_modelColor = Colors.orange; // Low Performance
      } else {
        bkg_modelColor = Colors.red; // Critical
      }

      return RegionModel(
        routeType: 'MODEL',
        title: displayName,
        regionCode: null,
        percentage: freshPctg,
        actual: freshActual,
        target: freshTarget,
        color: bkg_modelColor,
        yoy: '0.0% MTD',
        yoyColor: Colors.blue,
        icon: Icons.directions_car,
      );
    }).toList();

    // 4. BREAK THE LOOP: Check if the list actually changed before notifying
    if (modelData.length != newModels.length ||
        (modelData.isNotEmpty &&
            modelData.first.actual != newModels.first.actual)) {
      modelData = newModels;

      // Push the state update safely outside the current layout calculation phase
      Future.microtask(() => notifyListeners());
    }
  }

  void setView(bool isRegion) {
    isRegionView = isRegion;
    notifyListeners();
  }

  List<RegionModel> get currentData => isRegionView ? regionData : modelData;
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  late Future<List<dynamic>> _apiRequestsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _apiRequestsFuture = Future.wait([
      // Api().get_actMntReg(), // Index 0
      Api().get_actMntBkg(), // Index 0
      // Api().get_tgtMntReg(), // Index 1
      Api().get_tgtMntBkg(), // Index 1
      // Api().get_RegionListMntReg(), // Index 2
      Api().get_RegionListMntBkg(), // Index 2
      Api().get_mntBkgModelListActual(), // Index 3
      Api().get_currDate(), // Index 4
      Api().get_modelMaintenance_fmrid(), // Index 5
      Api().get_mntBkgModelListTarget(), // Index 6
    ]);
  }

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

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardData>(context);
    final data = dashboard.currentData;

    /*// 1. Extract the arguments map safely
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // 2. Fallback values if arguments or keys are null
    final String displayTitle = args?['title'] ?? 'Function List';
    final String displayMonth = args?['month'] ?? '[month]';
    final String displayYear = args?['year'] ?? '[year]';*/

    // 3. Fallback default values if the APIs fail or are loading
    String regActual = '00,000';
    String regTarget = '00,000';
    int raw_regActual = 0;
    int raw_regTarget = 0;
    // double regPcntge = 0.0;
    int regPcntge = 0;

    return FutureBuilder(
      future: _apiRequestsFuture,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
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

        // Real start
        // 3. Fallback default values if the APIs fail or are loading
        String curr_month_MM = '01';
        String curr_month_Mmm = 'Jan';
        String curr_year_YYYY = '1999';

        String regActual = '00,000';
        String regTarget = '00,000';
        String remainingTarget = '00,000';
        int raw_regActual = 0;
        int raw_regTarget = 0;
        int raw_remainingTarget = 0;
        // double regPcntge = 0.0;
        int regPcntge = 0;
        Color? reg_color = Colors.red;

        //print(snapshot.hasData);

        if (snapshot.hasData) {
          final List<dynamic> responses = snapshot.data!;

          if (responses[4]?['success'] == true &&
              responses[4]['data'].isNotEmpty) {
            var dataField = responses[0]['data'];
            List<dynamic> dataList = [];

            if (dataField is String) {
              dataList = jsonDecode(dataField);
            } else if (dataField is List) {
              dataList = dataField;
            }

            curr_month_MM = responses[4]['data'][0]['curr_month'] ?? 0;
            curr_year_YYYY = responses[4]['data'][0]['curr_year'] ?? 0;

            int monthNumber = int.parse(curr_month_MM);
            int yearNumber = int.parse(curr_year_YYYY);
            DateTime tempMMMDate = DateTime(yearNumber, monthNumber);

            curr_month_Mmm = DateFormat('MMM').format(tempMMMDate);
          }

          if (responses[0]?['success'] == true &&
              responses[0]['data'].isNotEmpty) {
            var dataField = responses[0]['data'];
            List<dynamic> dataList = [];

            if (dataField is String) {
              dataList = jsonDecode(dataField);
            } else if (dataField is List) {
              dataList = dataField;
            }

            if (dataList.isNotEmpty) {
              final rawValue = dataList[0]['total_bkg_month'];
              raw_regActual = rawValue;
              // print(raw_regActual);
              // raw_regActual = responses[0]['data'][0]['total_bkg_month'] ?? 0;
              final parsedValue = int.tryParse(rawValue?.toString() ?? '') ?? 0;

              regActual = NumberFormat.decimalPattern().format(parsedValue);

              if (regActual == '0') {
                regActual = '00,000';
              }
              // PUSH DATA TO YOUR LIST HERE:
              // dashboard.updateCentral2Actual('111', '222', '11.2');
            }
          }

          if (responses[1]?['success'] == true &&
              responses[1]['data'].isNotEmpty) {
            var dataField = responses[1]['data'];
            List<dynamic> dataList = [];

            if (dataField is String) {
              dataList = jsonDecode(dataField);
            } else if (dataField is List) {
              dataList = dataField;
            }

            if (dataList.isNotEmpty) {
              final rawValue = dataList[0]['TARGET_BKG_MONTH'];
              raw_regTarget = rawValue;
              // print(raw_regTarget);
              // raw_regTarget = responses[1]['data'][0]['total_bkg_month'] ?? 0;
              final parsedValue = int.tryParse(rawValue?.toString() ?? '') ?? 0;

              regTarget = NumberFormat.decimalPattern().format(parsedValue);

              if (regTarget == '0') {
                regTarget = '00,000';
              }
            }
          }

          if (responses[2]?['success'] == true &&
              responses[2]['data'].isNotEmpty) {
            //print('test: ${responses[2]['data']}');
            // print('test: ${responses[2]['data'][0]['BKG_PCTG_1']}');
            // print('test: ${responses[2]['data'][1]['BKG_PCTG_1']}');

            // PUSH DATA TO YOUR LIST HERE:
            // dashboard.updateCentral2Actual('111', '222', '11.2');
            dashboard.updateRegionsFromData(responses[2]['data']);
          }

          if (responses[3]?['success'] == true &&
              responses[3]['data'].isNotEmpty) {
            // PUSH DATA TO YOUR LIST HERE:
            // dashboard.updateModelFromData(responses[3]['data']);
            dashboard.updateModelFromData2(
              responses[3]['data'],
              responses[5]['data'],
              responses[6]['data'],
            );
          }
        }

        double d_mntRegPctg = 0.0;
        String s_mntRegPctg = '';
        Color c_regColor = Colors.grey;

        if (regActual != '00,000' && regTarget != '00,000') {
          //
          raw_remainingTarget = raw_regTarget - raw_regActual;
          if (raw_remainingTarget < 0) {
            raw_remainingTarget = 0;
          }

          // remainingTarget = NumberFormat.decimalPattern().format(30000);
          remainingTarget = NumberFormat.decimalPattern().format(
            raw_remainingTarget,
          );

          //calculate percentage daus
          d_mntRegPctg = (raw_regActual / raw_regTarget) * 100;
          s_mntRegPctg = d_mntRegPctg.toStringAsFixed(1);

          if (d_mntRegPctg > 99) {
            c_regColor = Colors.green;
          } else if (d_mntRegPctg > 70) {
            c_regColor = Colors.blue;
          } else if (d_mntRegPctg > 50) {
            c_regColor = Colors.yellow;
          } else if (d_mntRegPctg > 25) {
            c_regColor = Colors.orange;
          } else {
            c_regColor = Colors.red;
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
              // title,
              'Booking',
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
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text('${curr_month_Mmm} ' + Api.currYear),
                  onTap: () => _selectMonthYear(context),
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Actual Registration Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      // color: Color.fromRGBO(252, 245, 230, 0.5),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                            'BOOKING [ ${curr_month_Mmm.toUpperCase()} ]',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'ACTUAL BOOKING',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                // '82,198',
                                regActual,
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Circular Progress
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: CircularProgressIndicator(
                                    value: d_mntRegPctg / 100,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      c_regColor,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$s_mntRegPctg%',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: c_regColor,
                                      ),
                                    ),
                                    Text(
                                      'of $regTarget',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              color: c_regColor,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$s_mntRegPctg% of target achieved',
                              style: TextStyle(
                                color: c_regColor,
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
                            value: d_mntRegPctg / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              c_regColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            //_buildTargetInfo('TARGET', '360,000'),
                            _buildTargetInfo('TARGET', regTarget),
                            const Spacer(),
                            // _buildTargetInfo('REMAINING','277,802',alignRight: true,),
                            _buildTargetInfo(
                              'REMAINING',
                              remainingTarget,
                              alignRight: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tabs
                  Row(
                    children: [
                      _buildTab(
                        context,
                        'Region',
                        Icons.location_on,
                        dashboard.isRegionView,
                        () => dashboard.setView(true),
                      ),
                      const SizedBox(width: 12),
                      _buildTab(
                        context,
                        'Model',
                        Icons.directions_car,
                        !dashboard.isRegionView,
                        () => dashboard.setView(false),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Region Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    // childAspectRatio: 1.05,
                    childAspectRatio: 0.85,
                    children: [
                      //...data.map<Widget>((item) => _buildTestRegionCard(item)).toList(),
                      ...data.map<Widget>((item) {
                        return InkWell(
                          onTap: () {
                            // Create the arguments map with data from your current item loop
                            // print('parameter: ${item.regionCode}');
                            final routeArgs = {
                              'title': 'Booking',
                              'region_name': item.title,
                              'region_code': item.regionCode,
                              'model_name': item.title,
                            };

                            if (item.routeType == 'REGION') {
                              Navigator.pushNamed(
                                context,
                                '/bkgdetaillist',
                                arguments: routeArgs,
                              );
                            } else if (item.routeType == 'MODEL') {
                              Navigator.pushNamed(
                                context,
                                '/bkgdetaillistVariantAll',
                                arguments: routeArgs,
                              );
                              null;
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/bkgdetaillist',
                                arguments: routeArgs,
                              );
                            }
                          },
                          child: _buildTestRegionCard(
                            item,
                          ), // Renders your card UI layout design
                        );
                      }).toList(),
                      /*_buildRegionCard(
                        title: 'TEST',
                        percentage: '57.3%',
                        color: Colors.green,
                        actual: '1,746',
                        target: '3,046',
                        yoy: '+13.1% MTD',
                        yoyColor: Colors.green,
                        onTap: () {
                          /*Navigator.push(
                            context,
                            //MaterialPageRoute(builder: (context) => HomePage()),
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailList(title: 'test - Yearly target'),
                              //BookingScreen(),
                            ),
                          );*/
                          Navigator.pushNamed(context, '/detaillist');
                        },
                      ),*/
                    ],
                    /* children: [
                      _buildRegionCard(
                        title: 'CENTRAL 1',
                        percentage: '57.3%',
                        color: Colors.green,
                        actual: '1,746',
                        target: '3,046',
                        yoy: '+13.1% MTD',
                        yoyColor: Colors.green,
                        onTap: () {
                          /*Navigator.push(
                            context,
                            //MaterialPageRoute(builder: (context) => HomePage()),
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailList(title: 'test - Yearly target'),
                              //BookingScreen(),
                            ),
                          );*/
                          Navigator.pushNamed(context, '/detaillist');
                        },
                      ),
                      _buildRegionCard(
                        title: 'CENTRAL 2',
                        percentage: '201.2%',
                        color: Colors.green,
                        actual: regActual,,
                        target: '1,023',
                        yoy: '+12.1% MTD',
                        yoyColor: Colors.green,
                        onTap: () {
                          Navigator.pushNamed(context, '/registrationpage_test');
                        },
                      ),
                      _buildRegionCard(
                        title: 'CENTRAL 3',
                        percentage: '21.5%',
                        color: Colors.orange,
                        actual: '438',
                        target: '2,041',
                        yoy: '+15.7% MTD',
                        yoyColor: Colors.green,
                      ),
                      _buildRegionCard(
                        title: 'CENTRAL 4',
                        percentage: '24.5%',
                        color: Colors.orange,
                        actual: '325',
                        target: '1,325',
                        yoy: '+58.8% MTD',
                        yoyColor: Colors.green,
                      ),
                    ], */
                  ),

                  const SizedBox(height: 24),

                  // Last Updated
                  /* Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Last updated: 23 May 2025, 09:41 AM',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // Space for bottom nav
                  */
                ],
              ),
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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTab(
    BuildContext context,
    String title,
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.blue : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionCard({
    required String title,
    required String percentage,
    required Color color,
    required String actual,
    required String target,
    required String yoy,
    required Color yoyColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.blue, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: double.parse(percentage.replaceAll('%', '')) / 100,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actual',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      actual,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Target',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      target,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_upward, color: yoyColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    yoy,
                    style: TextStyle(
                      color: yoyColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestRegionCard(RegionModel item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // const Icon(Icons.business, color: Colors.grey, size: 22),
              Icon(item.icon, color: Colors.grey, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.percentage ?? '',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: item.color,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: double.parse(item.percentage.replaceAll('%', '')) / 100,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actual',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    item.actual,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Target',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    item.target,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
