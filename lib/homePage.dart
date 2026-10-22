// ignore: file_names
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test_1/global.dart';
import 'package:test_1/model/services/Api.dart';
import 'registration/reg_functionList.dart';
import 'package:test_1/utils/filter_utils.dart';

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
    _loadData();
  }

  //reload
  void _loadData() {
    _apiRequestsFuture = Future.wait([
      Api().get_actMntReg(), // Index 0
      Api().get_tgtMntReg(), // Index 1
      Api().get_actYearReg(), // Index 2
      Api.get_tgtYearReg(), // Index 3
      Api().get_actMntBkg(), // Index 4
      Api().get_tgtMntBkg(), // Index 5
      Api().get_AckRegistration(), // Index 6
      Api().get_userACL(), // Index 7
      Api().get_ackReg(), // Index 8 // Temp data in replace for no 6
      Api().get_currDate(), // Index 9
    ]);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadData(); // Triggers a reload of your data blueprints
    });
    // Waits for the new future bundle to finish completing before hiding the spinner
    await _apiRequestsFuture;
  }

  // Moved to filter_utils.dart
  /* Future<void> _selectMonthYear(BuildContext context) async {
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
  } */

  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return FutureBuilder<List<dynamic>>(
      // Fire all your API requests at the same time in parallel
      future: _apiRequestsFuture,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        // 1. Perform error handling if error while connection to DB
        if (snapshot.hasError) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context)
                        .size
                        .height, // Forces it to take up the full screen height
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          size: 64,
                          color: Colors.grey,
                        ),
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
        // Date format
        String curr_month_MM = '01';
        String curr_month_Mmm = 'Jan';
        String curr_year_YYYY = '1999';

        // ------NEW PARAMETER---------------------------
        var api_datafield_yearRegAct;
        var api_datafield_yearRegTgt;
        var api_datafield_mntRegAct;
        var api_datafield_mntRegTgt;
        var api_datafield_ack;
        var api_datafield_mntBkgAct;
        var api_datafield_mntBkgTgt;

        List<dynamic> list_yearRegActual = [];
        List<dynamic> list_yearRegTarget = [];
        List<dynamic> list_mntRegActual = [];
        List<dynamic> list_mntRegTarget = [];
        List<dynamic> list_ack = [];
        List<dynamic> list_mntBkgActual = [];
        List<dynamic> list_mntBkgTarget = [];

        // Registration
        String s_regActual_yearly = '00,000';
        String s_regTarget_yearly = '00,000';
        String s_regActual_mntly = '00,000';
        String s_regTarget_mntly = '00,000';
        String s_regPctg_yearly = '0';
        String s_regPctg_mntly = '0';
        String s_regRemaining_yearly = '0';
        String s_regShortage = '00.0k';
        String s_regShortageText = 'N/A';

        int i_regAck = 0;
        int i_regAck_yearly = 0;
        int i_regActual_yearly = 0;
        int i_regActual_mntly = 0;
        int i_regTarget_yearly = 0;
        int i_regTarget_mntly = 0;
        int i_regRemaining_yearly = 0;
        int i_regPctg_mntly = 0;
        int i_regShortage = 0;

        double d_regPctg_yearly = 0.0;

        Color c_regColor = Colors.red;
        Color c_regShortageColor = Colors.grey;

        //
        //
        // Booking
        String s_bkgActual_mntly = '00,000';
        String s_bkgTarget_mntly = '00,000';
        String s_bkgPctg_mntly = '0';
        String s_bkgShortage = '00.0k';
        String s_bkgShortageText = 'N/A';

        int i_bkgActual_mntly = 0;
        int i_bkgTarget_mntly = 0;
        int i_bkgPctg_mntly = 0;
        int i_bkgShortage = 0;

        Color c_bkgColor = Colors.red;
        Color c_bkgShortageColor = Colors.grey;

        /// END new parameter

        // daily ACK amount
        String regACK = '0';
        int rawRegACK = 0;
        int rawRegACK_forYear = 0;
        int rawRegActual_Ack = 0;

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
        String rawRegactual_str = '';
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

          if (responses[9]?['success'] == true &&
              responses[9]['data'].isNotEmpty) {
            var dataField = responses[0]['data'];
            List<dynamic> dataList = [];

            if (dataField is String) {
              dataList = jsonDecode(dataField);
            } else if (dataField is List) {
              dataList = dataField;
            }

            curr_month_MM = responses[9]['data'][0]['curr_month'] ?? 0;
            curr_year_YYYY = responses[9]['data'][0]['curr_year'] ?? 0;

            int monthNumber = int.parse(curr_month_MM);
            int yearNumber = int.parse(curr_year_YYYY);
            DateTime tempMMMDate = DateTime(yearNumber, monthNumber);

            curr_month_Mmm = DateFormat('MMM').format(tempMMMDate);
          }

          // Registration monthly math logic START
          // Get today ack value
          // print('Global Date Month: ' + globalCurrentMonth);
          // print('Global Date Year: ' + globalCurrentYear);
          // print('Query Date Month: ' + Api.currMonth);
          // print('Query Date Year: ' + Api.currYear);

          // Store API data in list variable
          // Api().get_actMntReg() - Index 0
          if (responses[0]?['success'] == true &&
              responses[0]['data'].isNotEmpty) {
            // Create a datafield list
            api_datafield_mntRegAct = responses[0]['data'] ?? [];

            // Convert datafield to list
            if (api_datafield_mntRegAct is String) {
              list_mntRegActual = jsonDecode(api_datafield_mntRegAct);
            } else if (api_datafield_mntRegAct is List) {
              list_mntRegActual = api_datafield_mntRegAct;
            }
          }

          // Api().get_tgtMntReg() - Index 1
          if (responses[1]?['success'] == true &&
              responses[1]['data'].isNotEmpty) {
            api_datafield_mntRegTgt = responses[1]['data'] ?? [];

            // Convert datafield to list
            if (api_datafield_mntRegTgt is String) {
              list_mntRegTarget = jsonDecode(api_datafield_mntRegTgt);
            } else if (api_datafield_mntRegTgt is List) {
              list_mntRegTarget = api_datafield_mntRegTgt;
            }
          }

          // Api().get_AckRegistration() - Index 6
          if (responses[6]?['success'] == true &&
              responses[6]['data'].isNotEmpty) {
            api_datafield_ack = responses[6]['data'] ?? [];

            // Convert datafield to list
            if (api_datafield_ack is String) {
              list_ack = jsonDecode(api_datafield_ack);
            } else if (api_datafield_ack is List) {
              list_ack = api_datafield_ack;
            }
          }

          // Api().get_actYearReg() - Index 2
          if (responses[2]?['success'] == true &&
              responses[2]['data'].isNotEmpty) {
            api_datafield_yearRegAct = responses[2]['data'] ?? [];
            // print('year_act_api');
            // print(api_datafield_yearRegAct);

            // Convert datafield to list
            if (api_datafield_yearRegAct is String) {
              list_yearRegActual = jsonDecode(api_datafield_yearRegAct);
            } else if (api_datafield_yearRegAct is List) {
              list_yearRegActual = api_datafield_yearRegAct;
            }
          }

          // Api.get_tgtYearReg() - Index 3
          if (responses[3]?['success'] == true &&
              responses[3]['data'].isNotEmpty) {
            api_datafield_yearRegTgt = responses[3]['data'];

            // Convert datafield to list
            if (api_datafield_yearRegTgt is String) {
              list_yearRegTarget = jsonDecode(api_datafield_yearRegTgt);
            } else if (api_datafield_yearRegTgt is List) {
              list_yearRegTarget = api_datafield_yearRegTgt;
            }
          }

          // Api.get_actMntBkg() - Index 4
          if (responses[4]?['success'] == true &&
              responses[4]['data'].isNotEmpty) {
            api_datafield_mntBkgAct = responses[4]['data'];
            // total_bkg_month

            if (api_datafield_mntBkgAct is String) {
              list_mntBkgActual = jsonDecode(api_datafield_mntBkgAct);
            } else if (api_datafield_mntBkgAct is List) {
              list_mntBkgActual = api_datafield_mntBkgAct;
            }
          }

          // Api().get_tgtMntBkg(), // Index 5
          if (responses[5]?['success'] == true &&
              responses[5]['data'].isNotEmpty) {
            api_datafield_mntBkgTgt = responses[5]['data'];
            // TARGET_BKG_MONTH

            if (api_datafield_mntBkgTgt is String) {
              list_mntBkgTarget = jsonDecode(api_datafield_mntBkgTgt);
            } else if (api_datafield_mntBkgTgt is List) {
              list_mntBkgTarget = api_datafield_mntBkgTgt;
            }
          }

          //
          //
          // END set API to variable

          // USE API list to set variable
          // declare ack variable
          if (list_ack.isNotEmpty) {
            if (globalCurrentMonth == Api.currMonth &&
                globalCurrentYear == Api.currYear) {
              i_regAck = list_ack[0]['AMOUNT'] ?? 0;
              // s_regAck = NumberFormat.decimalPattern().format(rawRegtarget);
            }

            if (globalCurrentYear == Api.currYear) {
              i_regAck_yearly = list_ack[0]['AMOUNT'] ?? 0;
            }
          }

          // declare monthly actual reg variable
          if (list_mntRegActual.isNotEmpty) {
            i_regActual_mntly = list_mntRegActual[0]['total_reg_month'] ?? 0;
            s_regActual_mntly = NumberFormat.decimalPattern().format(
              i_regActual_mntly,
            );
            if (s_regActual_mntly == '0') {
              s_regActual_mntly = '00,000';
            }
          }

          // declare monthly target reg variable
          if (list_mntRegTarget.isNotEmpty) {
            i_regTarget_mntly = list_mntRegTarget[0]['target_reg_month'] ?? 0;
            s_regTarget_mntly = NumberFormat.decimalPattern().format(
              i_regTarget_mntly,
            );
            if (s_regTarget_mntly == '0') {
              s_regTarget_mntly = '00,000';
            }
          }

          // declare yearly actual reg variable
          if (list_yearRegActual.isNotEmpty) {
            i_regActual_yearly = list_yearRegActual[0]['total_reg_year'] ?? 0;
            s_regActual_yearly = NumberFormat.decimalPattern().format(
              i_regActual_yearly,
            );
          }

          // declare yearly target reg variable
          if (list_yearRegTarget.isNotEmpty) {
            i_regTarget_yearly = list_yearRegTarget[0]['TARGET_REG_YEAR'] ?? 0;
            s_regTarget_yearly = NumberFormat.decimalPattern().format(
              i_regTarget_yearly,
            );
          }

          // declare monthly actual booking variable
          if (list_mntBkgActual.isNotEmpty) {
            i_bkgActual_mntly = list_mntBkgActual[0]['total_bkg_month'] ?? 0;
            s_bkgActual_mntly = NumberFormat.decimalPattern().format(
              i_bkgActual_mntly,
            );
            if (s_bkgActual_mntly == '0') {
              s_bkgActual_mntly = '00,000';
            }
          }

          // declare monthly target booking variable
          if (list_mntBkgTarget.isNotEmpty) {
            i_bkgTarget_mntly = list_mntBkgTarget[0]['TARGET_BKG_MONTH'] ?? 0;
            s_bkgTarget_mntly = NumberFormat.decimalPattern().format(
              i_bkgTarget_mntly,
            );
            if (s_bkgTarget_mntly == '0') {
              s_bkgTarget_mntly = '00,000';
            }
          }

          // END PARAMETER BASED ON API LIST

          //
          //
          //
          //
          //

          //
          // ADDITIONAL LOGIC & PARAMETER DECLARATION
          // get total reg + ack (ack value is 0 if not on the current month)
          i_regActual_mntly = i_regActual_mntly + i_regAck;
          s_regActual_mntly = NumberFormat.decimalPattern().format(
            i_regActual_mntly,
          );
          if (s_regActual_mntly == '0') {
            s_regActual_mntly = '00,000';
          }

          i_regActual_yearly = i_regActual_yearly + i_regAck_yearly;
          s_regActual_yearly = NumberFormat.decimalPattern().format(
            i_regActual_yearly,
          );

          // monthly shortage & color
          if (i_regTarget_mntly != 0) {
            i_regShortage = i_regActual_mntly - i_regTarget_mntly;

            if (i_regShortage > 0) {
              s_regShortageText = 'Surplus';
              c_regShortageColor = Colors.blue;
              s_regShortage =
                  '+${NumberFormat.compact().format(i_regShortage).toLowerCase()}';
            } else if (i_regShortage < 0) {
              s_regShortageText = 'Shortage';
              c_regShortageColor = Colors.pink;
              s_regShortage =
                  '${NumberFormat.compact().format(i_regShortage).toLowerCase()}';
            } else {
              s_regShortageText = 'Exact';
              c_regShortageColor = Colors.blue;
              s_regShortage = NumberFormat.compact()
                  .format(i_regShortage)
                  .toLowerCase();
            }
          }

          // monthly percentage & color
          if (i_regTarget_mntly != 0) {
            i_regPctg_mntly = (i_regActual_mntly * 100) ~/ i_regTarget_mntly;
            s_regPctg_mntly = i_regPctg_mntly.toStringAsFixed(1);

            if (i_regPctg_mntly > 99) {
              c_regColor = Colors.green;
            } else if (i_regPctg_mntly > 70) {
              c_regColor = Colors.blue;
            } else if (i_regPctg_mntly > 50) {
              c_regColor = Colors.yellow;
            } else if (i_regPctg_mntly > 25) {
              c_regColor = Colors.orange;
            } else {
              c_regColor = Colors.red;
            }
          }

          // yearly remaining
          i_regRemaining_yearly = i_regTarget_yearly - i_regActual_yearly;
          s_regRemaining_yearly = NumberFormat.decimalPattern().format(
            i_regRemaining_yearly,
          );

          // yearly percentage
          if (i_regTarget_yearly != 0) {
            d_regPctg_yearly = ((i_regActual_yearly * 100) / i_regTarget_yearly)
                .toDouble();
            s_regPctg_yearly = d_regPctg_yearly.toStringAsFixed(1);
          }

          if (i_bkgTarget_mntly != 0) {
            i_bkgPctg_mntly = (i_bkgActual_mntly * 100) ~/ i_bkgTarget_mntly;

            i_bkgShortage = i_bkgActual_mntly - i_bkgTarget_mntly;
            if (i_bkgShortage > 0) {
              s_bkgShortageText = 'Surplus';
              c_bkgShortageColor = Colors.blue;
              s_bkgShortage =
                  '+${NumberFormat.compact().format(i_bkgShortage).toLowerCase()}';
            } else if (i_bkgShortage < 0) {
              s_bkgShortageText = 'Shortage';
              c_bkgShortageColor = Colors.pink;
              s_bkgShortage =
                  '${NumberFormat.compact().format(i_bkgShortage).toLowerCase()}';
            } else {
              s_bkgShortageText = 'Exact';
              c_bkgShortageColor = Colors.blue;
              s_bkgShortage = NumberFormat.compact()
                  .format(i_bkgShortage)
                  .toLowerCase();
            }

            if (i_bkgPctg_mntly > 99) {
              c_bkgColor = Colors.green;
            } else if (i_bkgPctg_mntly > 70) {
              c_bkgColor = Colors.blue;
            } else if (i_bkgPctg_mntly > 50) {
              c_bkgColor = Colors.yellow;
            } else if (i_bkgPctg_mntly > 25) {
              c_bkgColor = Colors.orange;
            } else {
              c_bkgColor = Colors.red;
            }
          }

          // END ADDITIONAL LOGIC & PARAMETER DECLARATION

          //
          //
          //
          //

          // Registration yearly math logic START
          // Parse Registration Year Actual (Index 2)

          if (responses[7]?['success'] == true &&
              responses[7]['data'].isNotEmpty) {
            // print(responses[7]['data'][0]['ACL_REGISTRATION']);
            aclRegistration = responses[7]['data'][0]['ACL_REGISTRATION'];
            aclBooking = responses[7]['data'][0]['ACL_BOOKING'];
            aclParts = responses[7]['data'][0]['ACL_PARTS'];
            aclService = responses[7]['data'][0]['ACL_SERVICE'];
          }

          if (responses[7]?['success'] == true &&
              responses[7]['data'].isEmpty) {
            aclRegistration = 'N';
            aclBooking = 'N';
            aclParts = 'N';
            aclParts = 'N';
          }

          if (aclRegistration != 'Y') {
            //
            regMntActual = '00,000';
            regMntTarget = '00,000';
            regPcntge = 0;
            reg_color = Colors.grey;
            regPctgText = 'N/A';
            regShortage = '00.0k';
            regShortageColor = Colors.grey;
          }

          if (aclBooking != 'Y') {
            //
            bookMntActual = '00,000';
            bookMntTarget = '00,000';
            bookPcntge = 0;
            book_color = Colors.grey;
            bookPctgText = 'N/A';
            bookShortage = '00.0k';
            bookShortageColor = Colors.grey;
          }
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
                  // onTap: () => _selectMonthYear(context),  // Used filter_utils.dart
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
              // padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: SafeArea(
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
                                  children: [
                                    Text(
                                      'Welcome',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      // 'Ahmad Firdaus',
                                      '$globalUserName',
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          s_regActual_yearly,
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
                                            value: d_regPctg_yearly / 100,
                                            strokeWidth: 8,
                                            backgroundColor: Colors.grey[200],
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Colors.green),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$s_regPctg_yearly%',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                // color: Colors.green,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'of $s_regTarget_yearly',
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
                                    //
                                    const SizedBox(width: 16),
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
                                      '$s_regPctg_yearly% of target achieved',
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
                                    value: d_regPctg_yearly / 100,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color.fromARGB(255, 21, 212, 27),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    //_buildTargetInfo('TARGET', '360,000'),
                                    _buildTargetInfo(
                                      'TARGET',
                                      s_regTarget_yearly,
                                    ),
                                    const Spacer(),
                                    _buildTargetInfo(
                                      'REMAINING',
                                      s_regRemaining_yearly,
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
                                current: s_regActual_mntly,
                                target: s_regTarget_mntly,
                                percentage: i_regPctg_mntly,
                                //percentageColor: Colors.blue,
                                percentageColor: c_regColor,
                                // percentageText: s_regPctg_mntly,
                                percentageText: s_regShortageText,
                                change: s_regShortage,
                                changeColor: c_regShortageColor,
                                onTap: () {
                                  print("Registration module pressed");
                                  if (aclRegistration == 'Y') {
                                    //
                                    Navigator.pushNamed(
                                      localContext, // Uses the fresh localContext to trace routes safely
                                      '/detailpage2',
                                      arguments: {
                                        'title': 'Registration',
                                        'month': 'Jan',
                                        'year': '1999',
                                      },
                                    );
                                  } else {
                                    print(
                                      "User have no access to Registration module",
                                    );
                                  }
                                },
                              ),
                              _buildMetricCard(
                                icon: Icons.person,
                                title: 'Booking',
                                current: s_bkgActual_mntly,
                                target: s_bkgTarget_mntly,
                                percentage: i_bkgPctg_mntly,
                                percentageColor: c_bkgColor,
                                percentageText: s_bkgShortageText,
                                // change: '+0.0k',
                                change: s_bkgShortage,
                                changeColor: c_bkgShortageColor,
                                onTap: () {
                                  print("Booking module pressed");
                                  if (aclBooking == 'Y') {
                                    Navigator.pushNamed(
                                      localContext, // Uses the fresh localContext to trace routes safely
                                      '/bkgfunctionList',
                                      arguments: {
                                        'title': 'Booking',
                                        'month': 'May',
                                        'year': '2026',
                                      },
                                    );
                                  } else {
                                    print(
                                      "User have no access to Booking module",
                                    );
                                  }
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
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  target,
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
