import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test_1/model/detailListRegionOutlet_model.dart';
import 'package:test_1/model/detailListRegionSummary_model.dart';
import 'package:test_1/model/services/Api.dart';

class DetailListVariant extends StatefulWidget {
  //final String title;

  //const DetailListVariant({super.key, required this.title});
  const DetailListVariant({super.key});

  @override
  State<DetailListVariant> createState() => _DetailListVariantState();
}

class _DetailListVariantState extends State<DetailListVariant> {
  late Future<List<dynamic>> _apiReqFutureRegionList;
  bool _isInitialized = false; // Prevents multiple API calls

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // 1. Safe to get arguments here
      final args =
          ModalRoute.of(context)?.settings.arguments as DealerItemModel?;
      final String outletCode = args?.outletCode ?? 'Loading Outlet...';

      // 2. Pass the regionCode into your API function
      _apiReqFutureRegionList = Future.wait([
        Api().get_ModelListOfOutlet(outletCode), // Index 0
        Api().get_MntOutletModelSummary(outletCode), // Index 1
        Api().get_currDate(), // Index 2
      ]);

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract the class object passed from reg.dart route arguments
    final args = ModalRoute.of(context)?.settings.arguments as DealerItemModel?;

    // Optional: Guard fallback against crash conditions if opened directly
    final String outletName = args?.name ?? 'Loading Outlet...';
    final int actualCount = args?.actual ?? 0;
    final int targetCount = args?.target ?? 0;

    // Model summary
    List<SummaryCardModel> outletModelSummary = [
      SummaryCardModel(
        icon: Icons.trending_up,
        color: Colors.green,
        title: 'N/A',
        value: 'N/A',
      ),
    ];

    // List Model
    List<DealerItemModel> outletModelList = [
      /* DealerItemModel(
        rank: 1,
        medalColor: Colors.amber,
        name: '',
        actual: 0,
        target: 0,
        percentage: 0,
        status: '',
        statusColor: Colors.green,
        isGold: false,
      ), */
      DealerItemModel(
        rank: 1,
        medalColor: Colors.amber,
        name: 'AXIA - 1000H (CVT)',
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
        name: 'AXIA - 1000AV (CVT)',
        actual: 380,
        target: 367,
        percentage: 104,
        status: 'Above Target',
        statusColor: Colors.green,
        isGold: false,
      ),
    ];

    return FutureBuilder(
      future: _apiReqFutureRegionList,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        //Detect if the API is actively downloading data right now
        final bool isLoadingDealers =
            snapshot.connectionState == ConnectionState.waiting;

        String? total_gu_summary = 'N/A';
        String? average_achievement_pctg_summary = '0';
        String? need_attention_summary = 'N/A';

        String curr_month_MM = '01';
        String curr_month_Mmm = 'Jan';
        String curr_year_YYYY = '1999';

        if (snapshot.hasData) {
          final List<dynamic> responses = snapshot.data!;

          if (responses.isNotEmpty && responses[0]?['success'] == true) {
            final List<dynamic> rawDataList = responses[0]['data'];
            final List<DealerItemModel> parsedItems = [];

            for (int i = 0; i < rawDataList.length; i++) {
              //
              final item = rawDataList[i];
              final int currentRank = i + 1;

              // Safe numeric conversions from JSON types (ints/doubles)
              final int? actualCount = (item['ACTUAL_REG_COUNT'] as num?)
                  ?.toInt();
              final int? targetCount = (item['TARGET_REG_COUNT'] as num?)
                  ?.toInt();
              final bool isAboveTarget =
                  (actualCount ?? 0) >= (targetCount ?? 0);

              parsedItems.add(
                DealerItemModel(
                  rank: currentRank,
                  name: item['MODEL'] as String?,
                  outletCode: item['OUTLET_CODE'] as String?,
                  actual: actualCount,
                  target: targetCount,
                  percentage: (item['REG_PCTG'] as num?)?.toInt(),
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

            // OVERWRITE the mock list instantly during this render loop cycle
            outletModelList = parsedItems;
          }

          if (responses.isNotEmpty && responses[1]?['success'] == true) {
            if (responses[1]['data'].isNotEmpty) {
              //
              // total_gu_summary = responses[1]['data'][0]['TOTAL_ROWS'].toString() ?? '';
              average_achievement_pctg_summary =
                  responses[1]['data'][0]['AVERAGE_REG_PCTG'].toString() ?? '';
              need_attention_summary =
                  responses[1]['data'][0]['LOWEST_MODEL'].toString() ?? '';
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Registration',
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
          body: Column(
            children: [
              /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('Central 1', Icons.location_on),
                    const SizedBox(width: 8),
                    _buildFilterChip('May 2026', Icons.table_chart),
                  ],
                ),
              ), */
              const SizedBox(height: 10),
              /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // 'Motor Confidence',
                      outletName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
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
                    ),
                  ],
                ),
              ),*/
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Wrap in Expanded to calculate remaining width safely
                    Expanded(
                      child: Text(
                        outletName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        // 2. Add overflow and maxLines properties
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    // 3. Add a small spacing so the text doesn't touch the dropdown directly
                    const SizedBox(width: 16),
                    Row(
                      children: const [
                        Text('Sort by: '),
                        Text(
                          'Achievement',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.blue),
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
                  children: [
                    /* IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.people,
                              color: Colors.blue,
                              title: 'Gear Up',
                              // value: '35',
                              value: '$total_gu_summary',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.trending_up,
                              color: Colors.green,
                              title: 'Average Achievement',
                              // value: '92%',
                              value: '$average_achievement_pctg_summary%',
                            ),
                          ),
                          /*const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.emoji_events,
                              color: Colors.deepPurple,
                              title: 'Top Performer',
                              value: 'Motor\nConfidence',
                              isTopPerformer: true,
                            ),
                          ),*/
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.warning_amber_rounded,
                              color: Colors.red,
                              title: 'Need Attention',
                              // value: 'Ativa',
                              value: '$need_attention_summary',
                              //value: '-',
                              //subtitle: 'Dealers',
                            ),
                          ),
                        ],
                      ),
                    ), */
                    const SizedBox(height: 8),
                    /*...outletModelList.map((carModel) {
                      return _buildDealerItem(model: carModel);
                    }),*/
                    if (isLoadingDealers) ...[
                      /*_buildDealerShimmerSkeleton(),
                      _buildDealerShimmerSkeleton(),
                      _buildDealerShimmerSkeleton(),*/

                      //simple spinning wheel if you prefer:
                      const SizedBox(height: 80),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ] else if (snapshot.hasError) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('Failed to load backend data.'),
                        ),
                      ),
                    ] else ...[
                      //
                      ...outletModelList.map((carModel) {
                        return _buildDealerItem(model: carModel);
                      }),
                    ],
                    /*_buildDealerItem(
                      rank: 1,
                      medalColor: Colors.amber,
                      name: 'Bezza',
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
                      name: 'Axia',
                      actual: 380,
                      target: 367,
                      percentage: 104,
                      status: 'Above Target',
                      statusColor: Colors.green,
                    ),
                    _buildDealerItem(
                      rank: 3,
                      medalColor: Colors.orange,
                      name: 'Myvi',
                      actual: 368,
                      target: 367,
                      percentage: 100,
                      status: 'On Target',
                      statusColor: Colors.green,
                    ),
                    _buildDealerItem(
                      rank: 4,
                      name: 'Alza',
                      actual: 362,
                      target: 367,
                      percentage: 98,
                      status: 'Slightly Below',
                      statusColor: Colors.blue,
                      dotColor: Colors.blue,
                    ),
                    _buildDealerItem(
                      rank: 5,
                      name: 'Axia e',
                      actual: 257,
                      target: 367,
                      percentage: 70,
                      status: 'Below Target',
                      statusColor: Colors.orange,
                    ),
                    _buildDealerItem(
                      rank: 6,
                      name: 'Aruz',
                      actual: 200,
                      target: 367,
                      percentage: 54,
                      status: 'Well Below',
                      statusColor: Colors.red,
                    ),
                    _buildDealerItem(
                      rank: 7,
                      name: 'Traz',
                      actual: 183,
                      target: 367,
                      percentage: 50,
                      status: 'Well Below',
                      statusColor: Colors.red,
                    ),
                    _buildDealerItem(
                      rank: 8,
                      name: 'Ativa',
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

  Widget _buildDealerShimmerSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 72, // Matches the height of your standard ListTile container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Fake Rank Icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            // Fake Dealer Text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
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

  /*Widget _buildDealerItem({
    required int rank,
    Color? medalColor,
    required String name,
    required int actual,
    required int target,
    required int percentage,
    required String status,
    required Color statusColor,
    bool isGold = false,
    Color? dotColor,
    VoidCallback? onTap,
  }) { */
  Widget _buildDealerItem({required DealerItemModel model, Color? dotColor}) {
    // Safely extract values with null fallbacks to prevent division by zero crashes
    final int rank = model.rank ?? 0;
    final String name = model.name ?? 'Unknown Dealer';
    final int actual = model.actual ?? 0;
    final int target = model.target ?? 1; // Default to 1 (division cannot 0)
    final int percentage = model.percentage ?? 0;
    final String status = model.status ?? '';
    final Color statusColor = model.statusColor ?? Colors.grey;
    final bool isGold = model.isGold ?? false;
    final Color? medalColor = model.medalColor;

    // Perform the layout progress calculation safely
    // Safely calculate progress; if target is 0 or less, fall back to 0.0 directly
    final double progress = (target > 0)
        ? (actual / target).clamp(0.0, 1.5)
        : 0.0;

    return GestureDetector(
      onTap: () {},
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
                    color: dotColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.circle, color: dotColor, size: 14),
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
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
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
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  Text(
                    '$target Target',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                  color: percentage >= 100 ? Colors.green : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.replaceAll(' ', '\n'),
                  textAlign: TextAlign.center, //
                  style: TextStyle(
                    fontSize: 8,
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
