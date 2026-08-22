import 'package:flutter/material.dart';

import '../utility.dart';

class FoodTracking extends StatefulWidget {
  const FoodTracking({super.key});

  @override
  State<FoodTracking> createState() => _FoodTrackingState();
}

class _FoodTrackingState extends State<FoodTracking> {
  int totalCalories = 0;
  int totalProtein = 0;

  String datum = 
    '${DateTime.now().year.toString().padLeft(4, '0')}-'
    '${DateTime.now().month.toString().padLeft(2, '0')}-'
    '${DateTime.now().day.toString().padLeft(2, '0')}';


  late Future<List<Map<String, dynamic>>> currentTrackFuture;

  @override
  void initState() {
    super.initState();

    currentTrackFuture = DatabaseService().getTrackedValues(datum);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: currentTrackFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        
        if (!snapshot.hasData) {
          return const Text('Keine Daten gefunden');
        }
        final currentTrack = snapshot.data!;

        totalCalories = 0;
        totalProtein = 0;

        for (var obj in currentTrack) {
          totalCalories += obj['calories'] as int;
          totalProtein += obj['protein'] as int;
        }

        return Column(
          children: [
            Expanded(
              child: DataTable(
                showBottomBorder: true,
                horizontalMargin: 5,
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Protein')),
                  DataColumn(label: Text('Kalorien')),
                  DataColumn(label: Text('Essen')),
                  DataColumn(label: Text('Menge')),
                ],
                rows: List.generate(currentTrack.length, (index) {
                  return DataRow(
                    cells: [
                      DataCell(Text(currentTrack[index]['protein'].toString())),
                      DataCell(
                        Text(currentTrack[index]['calories'].toString()),
                      ),
                      DataCell(Text(currentTrack[index]['name'])),
                      DataCell(Text(currentTrack[index]['amount'].toString())),
                    ],
                  );
                }),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Gesamtkalorien: $totalCalories"),
                  Text("Gesamtprotein: $totalProtein"),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 75,
                height: 75,
                child: FloatingActionButton(
                  onPressed: () {},
                  tooltip: 'Neu hinzufügen',
                  child: const Icon(Icons.add, size: 40),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
