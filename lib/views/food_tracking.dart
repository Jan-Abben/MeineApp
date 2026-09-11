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
    String amount = '';

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
                onChanged: (value) => amount = value,
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
                if (name.isNotEmpty &&
                    amount.isNotEmpty &&
                    double.parse(amount.replaceAll(',', '.')) > 0) {
                  await DatabaseService().updateTrackingItem(
                    datum,
                    name,
                    double.parse(amount.replaceAll(',', '.')),
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

  void _showDatePickerDialog() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          datum =
              '${selectedDate.year.toString().padLeft(4, '0')}-'
              '${selectedDate.month.toString().padLeft(2, '0')}-'
              '${selectedDate.day.toString().padLeft(2, '0')}';
        });
        DatabaseService().createTrackingToday(datum);
      }
    });
  }

  int totalCalories = 0;
  int totalProtein = 0;

  String datum = '';

  @override
  void initState() {
    super.initState();

    datum =
        '${DateTime.now().year.toString().padLeft(4, '0')}-'
        '${DateTime.now().month.toString().padLeft(2, '0')}-'
        '${DateTime.now().day.toString().padLeft(2, '0')}';

    DatabaseService().createTrackingToday(datum);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$datum',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
                          showCheckboxColumn: false,
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
                              onSelectChanged: (selected) {
                                if (selected == true) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(currentTrack[index]['name']),
                                      content: FloatingActionButton(
                                        onPressed: () {
                                          DatabaseService().removeTrackingItemEntry(
                                            datum,
                                            currentTrack[index]['name'],
                                          );
                                          Navigator.pop(context);
                                        },
                                        tooltip: 'Löschen',
                                        child: const Icon(Icons.delete, size: 40),
                                      ),
                                    ),
                                  );
                                }
                              },
                              cells: [
                                DataCell(
                                  Text(
                                    currentTrack[index]['protein'].toString(),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    currentTrack[index]['calories'].toString(),
                                  ),
                                ),
                                DataCell(Text(currentTrack[index]['name'])),
                                DataCell(
                                  Text(
                                    currentTrack[index]['amount'].toString(),
                                  ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 75,
              height: 75,
              child: FloatingActionButton(
                onPressed: () {
                  _showDatePickerDialog();
                },
                tooltip: 'Datum ändern',
                child: const Icon(Icons.calendar_month, size: 40),
              ),
            ),
            SizedBox(
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
          ],
        ),
        
      ],
    );
  }
}
