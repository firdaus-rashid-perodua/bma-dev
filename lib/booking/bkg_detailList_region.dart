import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:marquee/marquee.dart';
import 'package:test_1/model/detailListRegionOutlet_model.dart';
import 'package:test_1/model/detailListRegionSummary_model.dart';
import 'package:test_1/model/services/Api.dart';

class DetailListRegionBkg extends StatefulWidget {
  //final String title;

  const DetailListRegionBkg({super.key});

  @override
  State<DetailListRegionBkg> createState() => _DetailListRegionBkgState();
}

class _DetailListRegionBkgState extends State<DetailListRegionBkg> {
  late Future<List<dynamic>> _apiReqFutureRegionList;
  bool _isInitialized = false; // Prevents multiple API calls

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // 1. Safe to get arguments here
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String?>;
      final String regionCode = args['region_code'] ?? 'Region Code';

      // 2. Pass the regionCode into your API function
      _apiReqFutureRegionList = Future.wait([
        // Api().get_RegionListMntRegOutlets(regionCode), // Index 0
        Api().get_RegionListMntBkgOutlets(regionCode), // Index 0
        Api().get_RegionMntRegOutletSummary(regionCode), // Index 1
        Api().get_currDate(), // Index 2
      ]);

      _isInitialized = true;
    }
  }

  @override
  /*void initState() {
    super.initState();
    _apiReqFutureRegionList = Future.wait([
      Api().get_RegionListMntRegOutlets(), // Index 0
    ]);
  }*/
  Widget build(BuildContext context) {
    // get arguments
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String?>;

    final String title = args['title'] ?? 'Default Title';
    final String region = args['region_name'] ?? 'Default Region';
    final String regionCode = args['region_code'] ?? 'Region Code';

    print('Pass data region: $regionCode');

    // List outlets
    List<SummaryCardModel> regionListDataSummary = [
      SummaryCardModel(
        icon: Icons.trending_up,
        color: Colors.green,
        title: 'N/A',
        value: 'N/A',
      ),
    ];

    List<DealerItemModel> regionListDataOutlet = [
      DealerItemModel(
        rank: 1,
        medalColor: Colors.amber,
        name: 'Motors Confidence (S) Sdn Bhd',
        actual: 452,
        target: 367,
        percentage: 123,
        status: 'Above Target',
        statusColor: Colors.green,
        isGold: true,
      ),
      DealerItemModel(
        rank: 2,
        medalColor: Colors.grey,
        name: 'DMM Shah Alam',
        actual: 380,
        target: 367,
        percentage: 104,
        status: 'Above Target',
        statusColor: Colors.green,
        isGold: false,
      ),
      DealerItemModel(
        rank: 3,
        medalColor: Colors.orange,
        name: 'YBK Shah Alam',
        actual: 368,
        target: 367,
        percentage: 100,
        status: 'On Target',
        statusColor: Colors.green,
      ),
      DealerItemModel(
        rank: 4,
        medalColor: Colors.orange,
        name: 'PSSB Puchong',
        actual: 362,
        target: 367,
        percentage: 98,
        status: 'On Target',
        statusColor: Colors.blue,
        dotColor: Colors.blue,
      ),
      DealerItemModel(
        rank: 5,
        medalColor: Colors.orange,
        name: 'Faresh Motors',
        actual: 257,
        target: 367,
        percentage: 70,
        status: 'Below Target',
        statusColor: Colors.orange,
      ),
    ];

    return FutureBuilder(
      future: _apiReqFutureRegionList,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        String? total_performed_outlets = '0';
        String? red_zone_area_outlets = '0';
        String? average_achievement_pctg = '0';
        String? top_performer_outlet = 'N/A';

        String curr_month_MM = '01';
        String curr_month_Mmm = 'Jan';
        String curr_year_YYYY = '1999';

        // 1. If the API is still downloading data, keep displaying your initial mock data
        if (snapshot.hasData) {
          final List<dynamic> responses = snapshot.data!;

          if (responses.isNotEmpty && responses[2]?['success'] == true) {
            //
            var dataField = responses[2]['data'];
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

          // Safely access your multi-future index 0 structure
          if (responses.isNotEmpty && responses[0]?['success'] == true) {
            final List<dynamic> rawDataList = responses[0]['data'];

            // Create a temporary list to hold the parsed API models
            final List<DealerItemModel> parsedItems = [];

            for (int i = 0; i < rawDataList.length; i++) {
              final item = rawDataList[i];
              final int currentRank = i + 1;

              // Safe numeric conversions from JSON types (ints/doubles)
              final int? actualCount = (item['ACTUAL_BKG_COUNT'] as num?)
                  ?.toInt();
              final int? targetCount = (item['TARGET_BKG_COUNT'] as num?)
                  ?.toInt();
              final bool isAboveTarget =
                  (actualCount ?? 0) >= (targetCount ?? 0);

              parsedItems.add(
                DealerItemModel(
                  rank: currentRank,
                  name: item['OUTLET_NAME'] as String?,
                  outletCode: item['OUTLET_CODE'] as String?,
                  actual: actualCount,
                  target: targetCount,
                  percentage: (item['BKG_PCTG'] as num?)?.toInt(),
                  status: isAboveTarget ? 'Above Target' : 'Below Target',
                  statusColor: isAboveTarget ? Colors.green : Colors.red,
                  isGold: currentRank == 1, // Marks rank #1 as Gold
                  medalColor: currentRank == 1
                      ? Colors.amber
                      : currentRank == 2
                      ? Colors.grey
                      : currentRank == 3
                      ? Colors.orange
                      : null,
                ),
              );
            }

            // 2. OVERWRITE the mock list instantly during this render loop cycle
            regionListDataOutlet = parsedItems;
          }

          if (responses.isNotEmpty && responses[1]?['success'] == true) {
            if (responses[1]['data'].isNotEmpty) {
              total_performed_outlets =
                  responses[1]['data'][0]['TOTAL_ROWS'].toString() ?? '';
              red_zone_area_outlets =
                  responses[1]['data'][0]['ROWS_BELOW_50'].toString() ?? '';
              average_achievement_pctg =
                  responses[1]['data'][0]['AVERAGE_BKG_PCTG'].toString() ?? '';
              top_performer_outlet =
                  responses[1]['data'][0]['HIGHEST_OUTLET_NAME'] ?? '';
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              // 'Registration $title $region',
              '$title',
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
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    /*Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search dealer',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),*/
                    Expanded(child: SizedBox(height: 10)),
                    const SizedBox(width: 8),
                    _buildFilterChip('$region', Icons.location_on),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      // 'May 2026',
                      '$curr_month_Mmm $curr_year_YYYY',
                      Icons.table_chart,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dealer Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    /* Row(
                      children: [
                        const Text('Sort by: '),
                        const Text(
                          'Achievement',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      ],
                    ), */
                    Row(
                      children: [
                        const Text('Sorted by '),
                        const Text(
                          'Achievement',
                          style: TextStyle(
                            // color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        //const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  //itemCount: regionListDataOutlet.length,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.people,
                              color: Colors.blue,
                              title: 'Total\nDealers',
                              value: '$total_performed_outlets',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.trending_up,
                              color: Colors.green,
                              title: 'Average Achievement',
                              value: '$average_achievement_pctg%',
                            ),
                          ),
                          /* const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.emoji_events,
                              color: Colors.deepPurple,
                              title: 'Top\nPerformer',
                              // value: 'Motor\nConfidenc',
                              value: '$top_performer_outlet',
                              isTopPerformer: true,
                            ),
                          ), */
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.warning_amber_rounded,
                              color: Colors.red,
                              title: 'Red Area',
                              value: '$red_zone_area_outlets',
                              subtitle: 'Dealers',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    // 2. DYNAMICALLY LOOP OVER YOUR MODEL ARRAY HERE
                    // The spread operator (...) unpacks the mapped list directly into the children layout
                    ...regionListDataOutlet.map((dealer) {
                      return _buildDealerItem(model: dealer);
                    }),
                    /*_buildDealerItem(
                      rank: 1,
                      medalColor: Colors.amber,
                      name: 'Motor Confidence',
                      actual: 452,
                      target: 367,
                      percentage: 123,
                      status: 'Above Target',
                      statusColor: Colors.green,
                      isGold: true,
                      onTap: () {
                        print("Outlet Pressed");
                        Navigator.pushNamed(context, '/detaillistModel');
                      },
                    ),
                    _buildDealerItem(
                      rank: 2,
                      medalColor: Colors.grey,
                      name: 'DMM Shah Alam',
                      actual: 380,
                      target: 367,
                      percentage: 104,
                      status: 'Above Target',
                      statusColor: Colors.green,
                    ),
                    _buildDealerItem(
                      rank: 3,
                      medalColor: Colors.orange,
                      name: 'YBK Shah Alam',
                      actual: 368,
                      target: 367,
                      percentage: 100,
                      status: 'On Target',
                      statusColor: Colors.green,
                    ),
                    _buildDealerItem(
                      rank: 4,
                      name: 'PSSB Puchong',
                      actual: 362,
                      target: 367,
                      percentage: 98,
                      status: 'Slightly Below',
                      statusColor: Colors.blue,
                      dotColor: Colors.blue,
                    ),
                    _buildDealerItem(
                      rank: 5,
                      name: 'Faresh Motors',
                      actual: 257,
                      target: 367,
                      percentage: 70,
                      status: 'Below Target',
                      statusColor: Colors.orange,
                    ),
                    _buildDealerItem(
                      rank: 6,
                      name: 'Lon G Sdn Bhd',
                      actual: 200,
                      target: 367,
                      percentage: 54,
                      status: 'Well Below',
                      statusColor: Colors.red,
                    ),
                    _buildDealerItem(
                      rank: 7,
                      name: 'PSSB Kota Damansara',
                      actual: 183,
                      target: 367,
                      percentage: 50,
                      status: 'Well Below',
                      statusColor: Colors.red,
                    ),
                    _buildDealerItem(
                      rank: 8,
                      name: 'PSSB Glenmarie',
                      actual: 0,
                      target: 367,
                      percentage: 0,
                      status: 'No Progress',
                      statusColor: Colors.grey,
                    ),*/
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    String? subtitle,
    bool isTopPerformer = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 20,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isTopPerformer ? 13 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDealerItem({required DealerItemModel model, Color? dotColor}) {
    // 1. Safely extract values with null fallbacks to prevent division by zero crashes
    final int rank = model.rank ?? 0;
    final String name = model.name ?? 'Unknown Dealer';
    final int actual = model.actual ?? 0;
    final int target = model.target ?? 1; // Default to 1 (division cannot 0)
    final int percentage = model.percentage ?? 0;
    final String status = model.status ?? '';
    final Color statusColor = model.statusColor ?? Colors.grey;
    final bool isGold = model.isGold ?? false;
    final Color? medalColor = model.medalColor;

    // 2. Perform the layout progress calculation safely
    // Safely calculate progress; if target is 0 or less, fall back to 0.0 directly
    final double progress = (target > 0)
        ? (actual / target).clamp(0.0, 1.5)
        : 0.0;

    return GestureDetector(
      //onTap: model.onTap,
      onTap: () {
        //
        Navigator.pushNamed(
          context,
          '/bkgdetaillistModel',
          arguments:
              model, // Sends all fields (name, actual, target, etc.) together
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rank <= 3)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: medalColor?.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.emoji_events, color: medalColor, size: 20),
                )
              else if (dotColor != null)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: dotColor?.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.circle, color: model.dotColor, size: 14),
                )
              else
                Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          title: LayoutBuilder(
            builder: (context, constraints) {
              const TextStyle textStyle = TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              );

              // Measure the exact pixel width of the string layout
              final textPainter = TextPainter(
                text: TextSpan(text: name, style: textStyle),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: double.infinity);

              // Check if text width exceeds the available container card width
              final bool isOverflowing =
                  textPainter.width > constraints.maxWidth;

              if (isOverflowing) {
                return SizedBox(
                  height: 24,
                  // Wrap with Align to anchor the animation viewport on the far left side
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Marquee(
                      // Keeps the animation stable across parent render ticks
                      key: ValueKey('marquee_$name'),
                      text: name,
                      style: textStyle,
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Align text baseline to the top/start
                      blankSpace: 40.0,
                      velocity: 25.0,

                      // --- PAUSE PROPERTIES ---
                      startAfter: const Duration(seconds: 4),
                      pauseAfterRound: const Duration(seconds: 7),
                    ),
                  ),
                );
              } else {
                return Text(
                  name,
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }
            },
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 8,
                    width: MediaQuery.of(context).size.width * 0.4 * progress,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$actual Actual',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  Text(
                    '$target Target',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: percentage! >= 100 ? Colors.green : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor?.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$status',
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
