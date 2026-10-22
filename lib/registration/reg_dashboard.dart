// ignore: file_names
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:test_1/global.dart';
import 'package:test_1/model/services/Api.dart';
import 'package:test_1/model/testRegionModel.dart';
import 'package:test_1/utils/filter_utils.dart';

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
  String regPctgMntly = '00.0';

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

  // Test method
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

  void updateRegionList(
    List<dynamic> apiDataList,
    Map<String, int> targetLookupRegion,
    Map<String, int> ackLookupRegion,
  ) {
    //
    final List<RegionModel> newRegions = apiDataList.map((row) {
      //
      Color c_regRegionColor;
      int i_mntRegRegionPctg_fn = 0;
      int i_mntRegRegionAct_fn = 0;
      int i_mntRegRegionTgt_lookup = 0;
      int i_ackCountRegion = 0;
      String s_RegionCode_fn = '';
      String s_RegionName_fn = '';
      String s_mntRegRegionAct_fn = '';
      String s_mntRegRegionTgt_lookup = '';

      s_RegionCode_fn = row['REGION']?.toString() ?? '';
      s_RegionName_fn = row['REGION_NAME']?.toString() ?? '';
      // print('s_RegionCode_fn: $s_RegionCode_fn');
      // print('s_RegionName_fn: $s_RegionName_fn');
      i_mntRegRegionAct_fn = row['ACTUAL_REG_COUNT'] ?? 0;
      s_mntRegRegionAct_fn = NumberFormat.decimalPattern().format(
        i_mntRegRegionAct_fn,
      );

      // Region target lookup
      i_mntRegRegionTgt_lookup = targetLookupRegion[s_RegionCode_fn] ?? 0;
      s_mntRegRegionTgt_lookup = NumberFormat.decimalPattern().format(
        i_mntRegRegionTgt_lookup,
      );

      // ack Region lookup
      if (globalCurrentMonth == Api.currMonth &&
          globalCurrentYear == Api.currYear) {
        i_ackCountRegion = ackLookupRegion[s_RegionCode_fn] ?? 0;
      } else {
        i_ackCountRegion = 0;
      }

      // additional logic
      // target + ack
      i_mntRegRegionAct_fn = i_mntRegRegionAct_fn + i_ackCountRegion;
      s_mntRegRegionAct_fn = NumberFormat.decimalPattern().format(
        i_mntRegRegionAct_fn,
      );

      if (i_mntRegRegionTgt_lookup != 0) {
        i_mntRegRegionPctg_fn =
            (i_mntRegRegionAct_fn * 100) ~/ i_mntRegRegionTgt_lookup;
      }

      if (i_mntRegRegionPctg_fn > 99) {
        c_regRegionColor = Colors.green;
      } else if (i_mntRegRegionPctg_fn > 70) {
        c_regRegionColor = Colors.blue;
      } else if (i_mntRegRegionPctg_fn > 50) {
        c_regRegionColor = Colors.yellow;
      } else if (i_mntRegRegionPctg_fn > 25) {
        c_regRegionColor = Colors.orange;
      } else {
        c_regRegionColor = Colors.red;
      }

      return RegionModel(
        routeType: 'REGION',
        title: s_RegionName_fn,
        regionCode: s_RegionCode_fn,
        outletCode: null,
        percentage: '$i_mntRegRegionPctg_fn%',
        actual: s_mntRegRegionAct_fn,
        target: s_mntRegRegionTgt_lookup,
        color: c_regRegionColor,
        yoy: '0.0% MTD',
        yoyColor: Colors.blue,
        icon: Icons.directions_car,
      );
    }).toList();

    if (regionData.length != newRegions.length ||
        (regionData.isNotEmpty &&
            regionData.first.actual != newRegions.first.actual)) {
      //
      regionData = newRegions;

      // Push the state update safely outside the current layout calculation phase
      Future.microtask(() => notifyListeners());
    }
  }

  void updateModelList(
    List<dynamic> apiDataList,
    Map<String, int> targetLookupModel,
    Map<String, int> ackLookupModel,
  ) {
    //
    final List<RegionModel> newModels = apiDataList.map((row) {
      //
      Color c_regModelColor;
      int i_mntRegModelPctg_fn = 0;
      int i_mntRegModelAct_fn = 0;
      int i_mntRegModelTgt_lookup = 0;
      int i_ackCountModel = 0;
      String s_modelName_fn = '';
      String s_mntRegModelAct_fn = '';
      String s_mntRegModelTgt_lookup = '';

      s_modelName_fn =
          row['MODEL']?.toString() ??
          // row['REGION']?.toString() ??
          'MODEL';
      // print('s_modelName: $s_modelName');
      i_mntRegModelAct_fn = row['TOTAL'] ?? 0;
      s_mntRegModelAct_fn = NumberFormat.decimalPattern().format(
        i_mntRegModelAct_fn,
      );

      // model target lookup
      i_mntRegModelTgt_lookup = targetLookupModel[s_modelName_fn] ?? 0;
      s_mntRegModelTgt_lookup = NumberFormat.decimalPattern().format(
        i_mntRegModelTgt_lookup,
      );

      // ack model lookup
      if (globalCurrentMonth == Api.currMonth &&
          globalCurrentYear == Api.currYear) {
        i_ackCountModel = ackLookupModel[s_modelName_fn] ?? 0;
      } else {
        i_ackCountModel = 0;
      }

      // additional logic
      // target + ack
      i_mntRegModelAct_fn = i_mntRegModelAct_fn + i_ackCountModel;
      s_mntRegModelAct_fn = NumberFormat.decimalPattern().format(
        i_mntRegModelAct_fn,
      );

      if (i_mntRegModelTgt_lookup != 0) {
        i_mntRegModelPctg_fn =
            (i_mntRegModelAct_fn * 100) ~/ i_mntRegModelTgt_lookup;
      }

      if (i_mntRegModelPctg_fn > 99) {
        c_regModelColor = Colors.green;
      } else if (i_mntRegModelPctg_fn > 70) {
        c_regModelColor = Colors.blue;
      } else if (i_mntRegModelPctg_fn > 50) {
        c_regModelColor = Colors.yellow;
      } else if (i_mntRegModelPctg_fn > 25) {
        c_regModelColor = Colors.orange;
      } else {
        c_regModelColor = Colors.red;
      }

      return RegionModel(
        routeType: 'MODEL',
        title: s_modelName_fn,
        regionCode: null,
        outletCode: null,
        percentage: '$i_mntRegModelPctg_fn%',
        actual: s_mntRegModelAct_fn,
        target: s_mntRegModelTgt_lookup,
        color: c_regModelColor,
        yoy: '0.0% MTD',
        yoyColor: Colors.blue,
        icon: Icons.directions_car,
      );
    }).toList();

    if (modelData.length != newModels.length ||
        (modelData.isNotEmpty &&
            modelData.first.actual != newModels.first.actual)) {
      //
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

//
//
//

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
    _loadData();
  }

  // reload
  void _loadData() {
    _apiRequestsFuture = Future.wait([
      Api().get_actMntReg(), // Index 0
      Api().get_tgtMntReg(), // Index 1
      Api().get_RegionListMntReg(), // Index 2
      Api().get_RegionListMntRegModel(), // Index 3
      // Api().get_ackReg(), // Index 4 //temp
      Api().get_AckRegistration(), // Index 4
      Api().get_AckRegistrationRegion(), // Index 5
      Api().get_AckRegistrationModel(), // Index 6
      Api().get_currDate(), // Index 7
      Api().get_mntModelListActual(), // Index 8
      Api().get_mntModelListTarget(), // Index 9
      Api().get_mntRegionListActual(), // Index 10
      Api().get_mntRegionListTarget(), // Index 11
    ]);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadData(); // Triggers a reload of your data blueprints
    });
    // Waits for the new future bundle to finish completing before hiding the spinner
    await _apiRequestsFuture;
  }

  Map<String, int> _buildAckLookupRegion(dynamic ackListResponse) {
    final Map<String, int> lookup = {};

    if (ackListResponse == null || ackListResponse is! Map) return lookup;
    if (ackListResponse['success'] != true) return lookup;

    final data = ackListResponse['data'];
    if (data is! List) return lookup;

    for (final row in data) {
      if (row is Map) {
        final regionCode = row['REGION_2']?.toString();
        final totalAck = (row['TOTAL_ACK'] as num?)?.toInt() ?? 0;
        if (regionCode != null) {
          lookup[regionCode] = totalAck;
        }
      }
    }

    return lookup;
  }

  Map<String, int> _buildTargetLookupRegion(dynamic targetListResponse) {
    final Map<String, int> lookup = {};

    if (targetListResponse == null || targetListResponse is! Map) return lookup;
    if (targetListResponse['success'] != true) return lookup;

    final data = targetListResponse['data'];
    if (data is! List) return lookup;

    for (final row in data) {
      if (row is Map) {
        final regionCode = row['REGION']?.toString();
        final regionTarget = (row['TARGET'] as num?)?.toInt() ?? 0;
        if (regionCode != null) {
          lookup[regionCode] = regionTarget;
        }
      }
    }

    return lookup;
  }

  Map<String, int> _buildTargetLookupModel(dynamic targetListResponse) {
    final Map<String, int> lookup = {};

    if (targetListResponse == null || targetListResponse is! Map) return lookup;
    if (targetListResponse['success'] != true) return lookup;

    final data = targetListResponse['data'];
    if (data is! List) return lookup;

    for (final row in data) {
      if (row is Map) {
        final modelCode = row['MODEL']?.toString();
        final modelTarget = (row['TARGET'] as num?)?.toInt() ?? 0;
        if (modelCode != null) {
          lookup[modelCode] = modelTarget;
        }
      }
    }

    return lookup;
  }

  Map<String, int> _buildAckLookupModel(dynamic ackListResponse) {
    final Map<String, int> lookup = {};

    if (ackListResponse == null || ackListResponse is! Map) return lookup;
    if (ackListResponse['success'] != true) return lookup;

    final data = ackListResponse['data'];
    if (data is! List) return lookup;

    for (final row in data) {
      if (row is Map) {
        final modelCode = row['MODEL']?.toString();
        final totalAck = (row['TOTAL_ACK'] as num?)?.toInt() ?? 0;
        if (modelCode != null) {
          lookup[modelCode] = totalAck;
        }
      }
    }

    return lookup;
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
        // ------NEW PARAMETER---------------------------
        var api_datafield_mntRegModelAct;
        var api_datafield_mntRegRegionAct;
        var api_datafield_mntRegActual;
        var api_datafield_mntRegAck;
        var api_datafield_mntRegTarget;

        List<dynamic> list_mntRegModelAct = [];
        List<dynamic> list_mntRegRegionAct = [];
        List<dynamic> list_mntRegActual = [];
        List<dynamic> list_mntRegAck = [];
        List<dynamic> list_mntRegTarget = [];

        String s_mntRegModelAct = '0,000';
        String s_mntRegRegionAct = '0,000';
        String s_mntRegActual = '00,000';
        String s_mntRegAck = '0';
        String s_mntRegTarget = '00,000';
        String s_mntRegPctg = '0.0';
        String s_mntRegRemaining = '0';

        int i_mntRegModelAct = 0;
        int i_mntRegRegionAct = 0;
        int i_mntRegActual = 0;
        int i_mntRegAck = 0;
        int i_mntRegTarget = 0;
        int i_mntRegRemaining = 0;

        double d_mntRegPctg = 0.0;

        Color c_regColor = Colors.grey;

        // ------END NEW PARAMETER---------------------------

        String curr_month_MM = '01';
        String curr_month_Mmm = 'Jan';
        String curr_year_YYYY = '1999';

        //print(snapshot.hasData);

        if (snapshot.hasData) {
          final List<dynamic> responses = snapshot.data!;

          // NEW API SET
          // Region actual
          if (responses[10]?['success'] == true &&
              responses[10]['data'].isNotEmpty) {
            api_datafield_mntRegRegionAct = responses[10]['data'];

            if (api_datafield_mntRegRegionAct is String) {
              list_mntRegRegionAct = jsonDecode(api_datafield_mntRegRegionAct);
            } else if (api_datafield_mntRegRegionAct is List) {
              list_mntRegRegionAct = api_datafield_mntRegRegionAct;
            }
          }

          //model actual
          if (responses[8]?['success'] == true &&
              responses[8]['data'].isNotEmpty) {
            api_datafield_mntRegModelAct = responses[8]['data'];

            if (api_datafield_mntRegModelAct is String) {
              list_mntRegModelAct = jsonDecode(api_datafield_mntRegModelAct);
            } else if (api_datafield_mntRegModelAct is List) {
              list_mntRegModelAct = api_datafield_mntRegModelAct;
            }
          }

          //month registration actual
          if (responses[0]?['success'] == true &&
              responses[0]['data'].isNotEmpty) {
            api_datafield_mntRegActual = responses[0]['data'];

            if (api_datafield_mntRegActual is String) {
              list_mntRegActual = jsonDecode(api_datafield_mntRegActual);
            } else if (api_datafield_mntRegActual is List) {
              list_mntRegActual = api_datafield_mntRegActual;
            }
          }

          //month registration ack
          if (responses[4]?['success'] == true &&
              responses[4]['data'].isNotEmpty) {
            api_datafield_mntRegAck = responses[4]['data'];

            if (api_datafield_mntRegAck is String) {
              list_mntRegAck = jsonDecode(api_datafield_mntRegAck);
            } else if (api_datafield_mntRegAck is List) {
              list_mntRegAck = api_datafield_mntRegAck;
            }
          }

          //month registration target
          if (responses[1]?['success'] == true &&
              responses[1]['data'].isNotEmpty) {
            api_datafield_mntRegTarget = responses[1]['data'];

            if (api_datafield_mntRegTarget is String) {
              list_mntRegTarget = jsonDecode(api_datafield_mntRegTarget);
            } else if (api_datafield_mntRegTarget is List) {
              list_mntRegTarget = api_datafield_mntRegTarget;
            }
          }

          // END NEW API SET

          //
          //
          //

          // Give api variable
          if (list_mntRegActual.isNotEmpty) {
            //
            i_mntRegActual = list_mntRegActual[0]['total_reg_month'];
            s_mntRegActual = NumberFormat.decimalPattern().format(
              i_mntRegActual,
            );
            if (s_mntRegActual == '0') {
              s_mntRegActual = '00,000';
            }
          }

          if (list_mntRegAck.isNotEmpty) {
            i_mntRegAck = list_mntRegAck[0]['AMOUNT'];
          }

          if (list_mntRegTarget.isNotEmpty) {
            i_mntRegTarget = list_mntRegTarget[0]['target_reg_month'];
            s_mntRegTarget = NumberFormat.decimalPattern().format(
              i_mntRegTarget,
            );
            if (s_mntRegTarget == '0') {
              s_mntRegTarget = '00,000';
            }
          }

          if (list_mntRegRegionAct.isNotEmpty) {
            //
            final LookupRegiontarget = _buildTargetLookupRegion(responses[11]);
            final LookupRegionack = _buildAckLookupRegion(responses[5]);
            dashboard.updateRegionList(
              list_mntRegRegionAct,
              LookupRegiontarget,
              LookupRegionack,
            );
          }

          if (list_mntRegModelAct.isNotEmpty) {
            // i_mntRegModelAct = list_mntRegModelAct[0]['TOTAL'] ?? 0;
            final LookupModeltarget = _buildTargetLookupModel(responses[9]);
            final LookupModelack = _buildAckLookupModel(responses[6]);
            dashboard.updateModelList(
              list_mntRegModelAct,
              LookupModeltarget,
              LookupModelack,
            );
          }

          // End Give api variable

          //
          //
          //

          // ADDITIONAL LOGIC
          i_mntRegActual = i_mntRegActual + i_mntRegAck;
          s_mntRegActual = NumberFormat.decimalPattern().format(i_mntRegActual);
          if (s_mntRegActual == '0') {
            s_mntRegActual = '00,000';
          }

          if (i_mntRegTarget > 0) {
            i_mntRegRemaining = i_mntRegTarget - i_mntRegActual;
            s_mntRegRemaining = NumberFormat.decimalPattern().format(
              i_mntRegRemaining,
            );

            d_mntRegPctg = (i_mntRegActual / i_mntRegTarget) * 100;
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

          // END ADDITIONAL LOGIC

          //
          //
          if (responses[7]?['success'] == true &&
              responses[7]['data'].isNotEmpty) {
            var dataField = responses[7]['data'];
            List<dynamic> dataList = [];

            if (dataField is String) {
              dataList = jsonDecode(dataField);
            } else if (dataField is List) {
              dataList = dataField;
            }

            curr_month_MM = responses[7]['data'][0]['curr_month'] ?? 0;
            curr_year_YYYY = responses[7]['data'][0]['curr_year'] ?? 0;

            int monthNumber = int.parse(curr_month_MM);
            int yearNumber = int.parse(curr_year_YYYY);
            DateTime tempMMMDate = DateTime(yearNumber, monthNumber);

            curr_month_Mmm = DateFormat('MMM').format(tempMMMDate);
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
              'Registration',
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
                  onTap: () async {
                    Navigator.pop(context); // Close drawer first

                    await FilterUtils.selectMonthYear(
                      context: context,
                      onDateSelected: () {
                        setState(() {
                          curr_month_Mmm = DateFormat('MMM').format(
                            DateTime(
                              int.parse(Api.currYear),
                              int.parse(Api.currMonth),
                            ),
                          );
                        });
                        _loadData();
                      },
                    );
                  },
                ),
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
                      // color: const Color.fromRGBO(252, 245, 230, 0.5),
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
                            'REGISTRATION [ ${curr_month_Mmm.toUpperCase()} ]',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'ACTUAL REGISTRATION',
                          style: TextStyle(
                            fontSize: 12,
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
                                s_mntRegActual,
                                // regActual,
                                style: TextStyle(
                                  fontSize: 38,
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: c_regColor,
                                      ),
                                    ),
                                    Text(
                                      'of $s_mntRegTarget',
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
                            // value: 0.228,
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
                            _buildTargetInfo('TARGET', s_mntRegTarget),
                            const Spacer(),
                            // _buildTargetInfo('REMAINING','277,802',alignRight: true,),
                            _buildTargetInfo(
                              'REMAINING',
                              s_mntRegRemaining,
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
                              // Navigator.pushNamed(
                              //   context,
                              //   '/detaillistModel',
                              //   arguments: routeArgs,
                              // );
                              null;
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
                  /* 
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
                    // fontSize: 15,
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
