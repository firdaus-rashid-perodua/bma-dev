// ignore: file_names
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:test_1/model/services/Api.dart';
import 'package:test_1/model/testRegionModel.dart';
// import 'package:oracledb/oracledb.dart';
// import 'detailList.dart';

class RegistrationAppWrapper extends StatelessWidget {
  const RegistrationAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DashboardData>(
      create: (context) => DashboardData(),
      // builder: (context, child) => RegistrationsScreen(),
      child: RegistrationsScreen(),
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
      title: 'ATIVA',
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
      String freshActual = _formatNumber(row['ACTUAL_REG_COUNT']);
      String freshTarget = _formatNumber(row['TARGET_REG_COUNT']);
      String freshPctg = '${row['REG_PCTG_1'] ?? '0.0'}%';
      String region_Code = '${row['REGION'] ?? ''}';
      Color reg_color = Colors.grey;

      if (row['REG_PCTG_1'] > 99.9) {
        reg_color = Colors.green;
      } else if (row['REG_PCTG_1'] > 69.9) {
        reg_color = Colors.blue;
      } else if (row['REG_PCTG_1'] > 49.9) {
        reg_color = Color(0xFFE6A100);
      } else if (row['REG_PCTG_1'] > 24.9) {
        reg_color = Colors.orange;
      } else {
        reg_color = Colors.red;
      }

      if (row['TARGET_REG_COUNT'] == 0) {
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
      String freshActual = _formatNumber(row['ACTUAL_REG_COUNT']);
      String freshTarget = _formatNumber(row['TARGET_REG_COUNT']);
      String freshPctg = '${row['REG_PCTG_1'] ?? '0.0'}%';
      Color reg_modelColor = Colors.grey;

      final double pctg =
          double.tryParse(row['REG_PCTG_1']?.toString() ?? '0') ?? 0.0;

      if (pctg >= 100.0) {
        reg_modelColor = Colors.green; // Deep Emerald Green (Excellent)
      } else if (pctg >= 70.0) {
        reg_modelColor = Colors.blue; // Dark Teal (On Track)
      } else if (pctg >= 50.0) {
        reg_modelColor = Color(
          0xFFE6A100,
        ); // Deep Amber/Gold (Warning - readable on white)
      } else if (pctg >= 25.0) {
        reg_modelColor = Colors.orange; // Burnt Orange (Low Performance)
      } else {
        reg_modelColor = Colors.red; // Crimson Red (Critical)
      }

      if (row['TARGET_REG_COUNT'] == 0) {
        reg_modelColor = Colors.grey;
      }

      return RegionModel(
        routeType: 'MODEL',
        title: displayName,
        regionCode: null,
        percentage: freshPctg,
        actual: freshActual,
        target: freshTarget,
        color: reg_modelColor,
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

  void setView(bool isRegion) {
    isRegionView = isRegion;
    notifyListeners();
  }

  List<RegionModel> get currentData => isRegionView ? regionData : modelData;
}

class RegistrationsScreen extends StatefulWidget {
  const RegistrationsScreen({super.key});

  @override
  State<RegistrationsScreen> createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends State<RegistrationsScreen> {
  late Future<List<dynamic>> _apiRequestsFuture;

  @override
  void initState() {
    super.initState();
    _apiRequestsFuture = Future.wait([
      Api().get_actMntReg(), // Index 0
      Api().get_tgtMntReg(), // Index 1
      Api().get_RegionListMntReg(), // Index 2
      Api().get_RegionListMntRegModel(), // Index 3
    ]);
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Real start
        // 3. Fallback default values if the APIs fail or are loading
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
              final rawValue = dataList[0]['total_reg_month'];
              raw_regActual = rawValue;
              // print(raw_regActual);
              // raw_regActual = responses[0]['data'][0]['total_reg_month'] ?? 0;
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
              final rawValue = dataList[0]['target_reg_month'];
              raw_regTarget = rawValue;
              // print(raw_regTarget);
              // raw_regTarget = responses[1]['data'][0]['total_reg_month'] ?? 0;
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
            // print('test: ${responses[2]['data'][0]['REG_PCTG_1']}');
            // print('test: ${responses[2]['data'][1]['REG_PCTG_1']}');

            // PUSH DATA TO YOUR LIST HERE:
            // dashboard.updateCentral2Actual('111', '222', '11.2');
            dashboard.updateRegionsFromData(responses[2]['data']);
          }

          if (responses[3]?['success'] == true &&
              responses[3]['data'].isNotEmpty) {
            // PUSH DATA TO YOUR LIST HERE:
            dashboard.updateModelFromData(responses[3]['data']);
          }
        }

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
              'Registration',
              //'$title',
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
                // Actual Registration Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
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
                          'REGISTRATION',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'ACTUAL REGISTRATION',
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
                                  value: 1.029,
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
                                    '102.9%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const Text(
                                    'of 30,500',
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
                          const Icon(
                            Icons.arrow_upward,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '102.9% of target achieved',
                            style: TextStyle(
                              color: Colors.green,
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
                          value: 0.228,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
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

                /*Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Region',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Model',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),*/
                const SizedBox(height: 24),

                // Region Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  // childAspectRatio: 0.85,
                  children: [
                    //...data.map<Widget>((item) => _buildTestRegionCard(item)).toList(),
                    ...data.map<Widget>((item) {
                      return InkWell(
                        onTap: () {
                          // Create the arguments map with data from your current item loop
                          // print('parameter: ${item.regionCode}');
                          final routeArgs = {
                            'title': 'Registration',
                            'region_name': item.title,
                            'region_code': item.regionCode,
                          };

                          if (item.routeType == 'REGION') {
                            Navigator.pushNamed(
                              context,
                              '/detaillist',
                              arguments: routeArgs,
                            );
                          } else if (item.routeType == 'MODEL') {
                            Navigator.pushNamed(
                              context,
                              '/detaillistModel',
                              arguments: routeArgs,
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/detaillist',
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
                            //RegistrationsScreen(),
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
                            //RegistrationsScreen(),
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
                Center(
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
              ],
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
                    fontSize: 15,
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
