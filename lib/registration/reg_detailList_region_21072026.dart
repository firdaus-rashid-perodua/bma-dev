import 'package:flutter/material.dart';
import 'package:test_1/model/detailListRegionOutlet_model.dart';
import 'package:test_1/model/detailListRegionSummary_model.dart';
import 'package:test_1/model/services/Api.dart';

class DetailListRegion extends StatefulWidget {
  //final String title;

  const DetailListRegion({super.key});

  @override
  State<DetailListRegion> createState() => _DetailListRegionState();
}

class _DetailListRegionState extends State<DetailListRegion> {
  late Future<List<dynamic>> _apiReqFutureRegionList;

  @override
  void initState() {
    super.initState();
    _apiReqFutureRegionList = Future.wait([
      Api().get_RegionListMntRegOutlets(''), // Index 0
    ]);
  }

  Widget build(BuildContext context) {
    // get arguments
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    final String title = args['title'] ?? 'Default Title';
    final String region = args['region'] ?? 'Default Region';

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
        name: 'Motors Confidence',
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
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('$region', Icons.location_on),
                    const SizedBox(width: 8),
                    _buildFilterChip('May 2026', Icons.table_chart),
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
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                              value: '35',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.trending_up,
                              color: Colors.green,
                              title: 'Average Achievement',
                              value: '92%',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.emoji_events,
                              color: Colors.deepPurple,
                              title: 'Top\nPerformer',
                              value: 'Motor\nConfidenc',
                              isTopPerformer: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.warning_amber_rounded,
                              color: Colors.red,
                              title: 'Need\nAttention',
                              value: '5',
                              subtitle: 'Dealers',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
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
                    ),*/
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
                    ),
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

  Widget _buildDealerItem({
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
  }) {
    final double progress = (actual / target).clamp(0.0, 1.5);
    return GestureDetector(
      onTap: onTap,
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
                  status,
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
