import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:marquee/marquee.dart';
import 'package:test_1/global.dart';
import 'package:test_1/model/detailListRegionOutlet_model.dart';
import 'package:test_1/model/detailListRegionSummary_model.dart';
import 'package:test_1/model/services/Api.dart';
import 'package:test_1/utils/filter_utils.dart';

class DetailListRegion extends StatefulWidget {
  //final String title;

  const DetailListRegion({super.key});

  @override
  State<DetailListRegion> createState() => _DetailListRegionState();
}

class _DetailListRegionState extends State<DetailListRegion> {
  late Future<List<dynamic>> _apiReqFutureRegionList;
  bool _isInitialized = false; // Prevents multiple API calls
  String regionCode = 'Region Code'; // Store at class level to access anywhere
  //Point your chip text shortcuts directly to your new utility helper:
  String get displayRegionName => FilterUtils.getDisplayRegionName(regionCode);

  // Helper getter to format month from global state
  String get curr_month_Mmm {
    int monthNumber = int.tryParse(Api.currMonth) ?? 1;
    int yearNumber = int.tryParse(Api.currYear) ?? 2025;
    return DateFormat('MMM').format(DateTime(yearNumber, monthNumber));
  }

  String get curr_year_YYYY => Api.currYear;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String?>;
      regionCode = args['region_code'] ?? 'Region Code 2';

      _fetchRegionData(); // Fetch initially
      _isInitialized = true;
    }
  }

  // Callable method to refresh futures when filter changes
  void _fetchRegionData() {
    _apiReqFutureRegionList = Future.wait([
      Api().get_RegionListMntRegOutlets(regionCode),
      Api().get_RegionMntRegOutletSummary(regionCode),
      Api().get_currDate(),
      Api().get_AckRegistrationOutletList(),
    ]);
  }

  Map<String, int> _buildAckLookup(dynamic ackListResponse) {
    final Map<String, int> lookup = {};

    if (ackListResponse == null || ackListResponse is! Map) return lookup;
    if (ackListResponse['success'] != true) return lookup;

    final data = ackListResponse['data'];
    if (data is! List) return lookup;

    for (final row in data) {
      if (row is Map) {
        final outletCode = row['OUTLET_CODE']?.toString();
        final totalAck = (row['TOTAL_ACK'] as num?)?.toInt() ?? 0;
        if (outletCode != null) {
          lookup[outletCode] = totalAck;
        }
      }
    }

    return lookup;
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
                setState(() {
                  Api.currMonth = selectedMonth.toString().padLeft(2, '0');
                  Api.currYear = selectedYear.toString();
                  _fetchRegionData(); // Triggers API reload with new dates
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

  Future<void> _selectRegion(BuildContext context) async {
    // Define your region options mapping [Display Name : Backend Code]
    final Map<String, String> regions = {
      'Central 1': 'C1',
      'Central 2': 'C2',
      'East Coast 1': 'EC1',
      'East Coast 2': 'EC2',
      'East Malaysia': 'EM',
      'Northern': 'N',
      'Southern': 'S',
      // 'FMD': 'FMD',
    };

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height closely
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Region',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              // Generate list of items from your region map keys
              ...regions.keys.map((String key) {
                final isSelected = regionCode.toLowerCase() == regions[key];
                return ListTile(
                  title: Text(
                    key,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      // Update state to use chosen region backend identifier value
                      regionCode = regions[key]!;

                      // Instantly trigger an API reload for this newly mapped zone
                      _fetchRegionData();
                    });
                    Navigator.pop(context); // Close bottom menu panel
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
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

        if (snapshot.hasData) {
          final List<dynamic> responses = snapshot.data as List<dynamic>;

          final Map<String, int> ackLookup = _buildAckLookup(responses[3]);
          // final Map<String, int> ackLookup = responses.length > 3 ? _buildAckLookup(responses[3]) : <String, int>{};

          // --- RESPONSE INDEX 2: DATE INFORMATION ---
          if (responses.length > 2 && responses[2] != null) {
            final Map<String, dynamic> dateResponse =
                responses[2] as Map<String, dynamic>;

            if (dateResponse['success'] == true) {
              var dataField = dateResponse['data'];
              List<dynamic> dataList = [];

              if (dataField is String) {
                dataList = jsonDecode(dataField);
              } else if (dataField is List) {
                dataList = dataField;
              }

              if (dataList.isNotEmpty) {
                final Map<String, dynamic> dateItem =
                    dataList[0] as Map<String, dynamic>;
                curr_month_MM = dateItem['curr_month']?.toString() ?? '01';
                curr_year_YYYY = dateItem['curr_year']?.toString() ?? '1999';

                int monthNumber = int.tryParse(curr_month_MM) ?? 1;
                int yearNumber = int.tryParse(curr_year_YYYY) ?? 1999;
                DateTime tempMMMDate = DateTime(yearNumber, monthNumber);

                curr_month_Mmm = DateFormat('MMM').format(tempMMMDate);
              }
            }
          }

          // --- RESPONSE INDEX 0: REGION LIST OUTLETS ---
          if (responses.isNotEmpty && responses[0] != null) {
            final Map<String, dynamic> regionResponse =
                responses[0] as Map<String, dynamic>;

            if (regionResponse['success'] == true) {
              final List<dynamic> rawDataList = regionResponse['data'] ?? [];
              final List<DealerItemModel> parsedItems = [];

              for (int i = 0; i < rawDataList.length; i++) {
                final Map<String, dynamic> item =
                    rawDataList[i] as Map<String, dynamic>;
                final int currentRank = i + 1;

                final int? actualCount = (item['ACTUAL_REG_COUNT'] as num?)
                    ?.toInt();
                final int? targetCount = (item['TARGET_REG_COUNT'] as num?)
                    ?.toInt();

                // 🔹 O(1) lookup instead of parsing a nested per-outlet response
                final String outletCode = item['OUTLET_CODE']?.toString() ?? '';
                final int ackAmount = ackLookup[outletCode] ?? 0;

                final int combinedActual = (actualCount ?? 0) + ackAmount;
                final bool isAboveTarget = combinedActual >= (targetCount ?? 0);

                final regPercentage = (item['REG_PCTG'] as num?)?.toDouble();
                Color reg_color = Colors.grey;

                if (regPercentage != null) {
                  if (regPercentage > 99.9) {
                    reg_color = Colors.green;
                  } else if (regPercentage > 69.9) {
                    reg_color = Colors.blue;
                  } else if (regPercentage > 49.9) {
                    reg_color = const Color(0xFFE6A100);
                  } else if (regPercentage > 24.9) {
                    reg_color = Colors.orange;
                  } else {
                    reg_color = Colors.red;
                  }
                }

                parsedItems.add(
                  DealerItemModel(
                    rank: currentRank,
                    name: item['OUTLET_NAME'] as String?,
                    outletCode: item['OUTLET_CODE'] as String?,
                    actual: combinedActual,
                    target: targetCount,
                    percentage: (item['REG_PCTG'] as num?)?.toInt(),
                    status: isAboveTarget ? 'Above Target' : 'Below Target',
                    statusColor: reg_color,
                    isGold: currentRank == 1,
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
              regionListDataOutlet = parsedItems;
            }
          }

          // --- RESPONSE INDEX 1: OUTLET SUMMARY STATS ---
          if (responses.length > 1 && responses[1] != null) {
            final Map<String, dynamic> summaryResponse =
                responses[1] as Map<String, dynamic>;

            if (summaryResponse['success'] == true) {
              final List<dynamic> summaryData = summaryResponse['data'] ?? [];
              if (summaryData.isNotEmpty) {
                final Map<String, dynamic> summaryItem =
                    summaryData[0] as Map<String, dynamic>;

                total_performed_outlets =
                    summaryItem['TOTAL_ROWS']?.toString() ?? '0';
                red_zone_area_outlets =
                    summaryItem['ROWS_BELOW_50']?.toString() ?? '0';
                average_achievement_pctg =
                    summaryItem['AVERAGE_REG_PCTG']?.toString() ?? '0';
                top_performer_outlet =
                    summaryItem['HIGHEST_OUTLET_NAME']?.toString() ?? 'N/A';
              }
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
            /*actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {},
              ),
            ],*/
          ),
          body: Column(
            children: [
              SizedBox(height: 5),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: Row(
              //     children: [
              //       Expanded(child: SizedBox(height: 10)),
              //       const SizedBox(width: 8),
              //       _buildFilterChip('$region', Icons.location_on),
              //       const SizedBox(width: 8),
              //       _buildFilterChip(
              //         // 'May 2026',
              //         '$curr_month_Mmm $curr_year_YYYY',
              //         Icons.table_chart,
              //       ),
              //     ],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: SizedBox(height: 10)),
                    const SizedBox(width: 8),
                    // _buildFilterChip('$region', Icons.location_on),
                    GestureDetector(
                      onTap: () => _selectRegion(context),
                      child: _buildFilterChip(
                        // '$regionCode',
                        '$displayRegionName',
                        Icons.location_on,
                      ), // Shows selected region text
                    ),
                    const SizedBox(width: 8),

                    // Make your chip clickable:
                    GestureDetector(
                      onTap: () => _selectMonthYear(context),
                      child: _buildFilterChip(
                        '$curr_month_Mmm $curr_year_YYYY',
                        Icons.table_chart,
                      ),
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
          '/detaillistModel',
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
