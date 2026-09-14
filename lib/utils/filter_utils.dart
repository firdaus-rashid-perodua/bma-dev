import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Import your api.dart path here so the utils file can see 'Api'
// import 'package:test_1/api.dart';
import 'package:test_1/model/services/Api.dart';

class FilterUtils {
  // Helper to convert C1, N, S, W to human-readable names anywhere
  static String getDisplayRegionName(String regionCode) {
    switch (regionCode.toUpperCase()) {
      case 'C1':
        return 'Central 1';
      case 'C2':
        return 'Central 2';
      case 'East Coast 1':
        return 'Central 1';
      case 'EC2':
        return 'East Coast 2';
      case 'EM':
        return 'East Malaysia';
      case 'N':
        return 'Northern';
      case 'S':
        return 'Southern';
      case 'FMD':
        return 'FMD';
      default:
        return regionCode;
    }
  }

  // REUSABLE MONTH/YEAR SELECTOR
  static Future<void> selectMonthYear({
    required BuildContext context,
    required VoidCallback onDateSelected, // Fires after date changes
  }) async {
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
                            onPressed: () =>
                                setDialogState(() => selectedMonth = index + 1),
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
                // Update global data values directly
                Api.currMonth = selectedMonth.toString().padLeft(2, '0');
                Api.currYear = selectedYear.toString();

                onDateSelected(); // Execute the local screen refresh logic
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // REUSABLE REGION SELECTOR
  static Future<void> selectRegion({
    required BuildContext context,
    required String currentRegionCode,
    required ValueChanged<String>
    onRegionSelected, // Returns chosen string back to screen
  }) async {
    final Map<String, String> regions = {
      'Central 1': 'C1',
      'Central 2': 'C2',
      'East Coast 1': 'EC1',
      'East Coast 2': 'EC2',
      'East Malaysia': 'EM',
      'Northern': 'N',
      'Southern': 'S',
      'FMD': 'FMD',
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Region',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              ...regions.keys.map((String key) {
                final isSelected =
                    currentRegionCode.toUpperCase() == regions[key];
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
                    onRegionSelected(
                      regions[key]!,
                    ); // Pass back selected code ('C1', etc.)
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
