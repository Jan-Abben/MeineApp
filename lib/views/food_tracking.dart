import 'package:flutter/material.dart';

import '../utility.dart';

class FoodTracking extends StatefulWidget {
  const FoodTracking({super.key});

  @override
  State<FoodTracking> createState() => _FoodTrackingState();
}

class _FoodTrackingState extends State<FoodTracking> {
  void _showAddTrackingDialog() {
    String name = '';
    double amount = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Essen hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) => amount = double.parse(value.replaceAll(',', '.')),
                decoration: InputDecoration(labelText: 'Menge'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name.isNotEmpty && amount > 0) {
                  await DatabaseService()
                      .updateTrackingItem(
                        datum,
                        name,
                        amount,
                      );
                      
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } else {
                  // Show an error message or handle the case where the name or ingredients are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bitte füllen Sie alle Felder aus.'),
                    ),
                  );
                }
              },
              child: Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  int totalCalories = 0;
  int totalProtein = 0;

  String datum = '';

  //late Future<List<Map<String, dynamic>>> currentTrackFuture;

  @override
  void initState() {
    super.initState();

    datum =
        '${DateTime.now().year.toString().padLeft(4, '0')}-'
        '${DateTime.now().month.toString().padLeft(2, '0')}-'
        '${DateTime.now().day.toString().padLeft(2, '0')}';

    datum = '2026-08-23'; // For testing purposes, set a fixed date

    DatabaseService().createTrackingToday(datum);
    //currentTrackFuture = DatabaseService().getTrackedValues(datum);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: DatabaseService().getTrackedValuesStream(datum),
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          showBottomBorder: true,
                          horizontalMargin: 10,
                          columnSpacing: 10,
                          columns: const [
                            DataColumn(label: Text('Protein')),
                            DataColumn(label: Text('Kalorien')),
                            DataColumn(label: Text('Essen')),
                            DataColumn(label: Text('Menge')),
                          ],
                          rows: List.generate(currentTrack.length, (index) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(currentTrack[index]['protein'].toString()),
                                ),
                                DataCell(
                                  Text(currentTrack[index]['calories'].toString()),
                                ),
                                DataCell(Text(currentTrack[index]['name'])),
                                DataCell(
                                  Text(currentTrack[index]['amount'].toString()),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
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
                ],
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            width: 75,
            height: 75,
            child: FloatingActionButton(
              onPressed: () {
                _showAddTrackingDialog();
              },
              tooltip: 'Neu hinzufügen',
              child: const Icon(Icons.add, size: 40),
            ),
          ),
        ),
      ],
    );
  }
}
