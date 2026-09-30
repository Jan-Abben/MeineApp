import 'package:flutter/material.dart';
import '../utility.dart';

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  Future<void> _showStandarddingeDialog() async {
    Map<String, dynamic> standarddinge = await DatabaseService()
        .getAllStandarddinge();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: Text('Standarddinge'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: standarddinge.length,
                  itemBuilder: (context, index) {
                    final item = standarddinge.entries.elementAt(index);
                    return CheckboxListTile(
                      title: Text(item.key.toString()),
                      value: item.value as bool,
                      onChanged: (value) {
                        setDialogState(() {
                          standarddinge[item.key] = value;
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Abbrechen'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        for (var item in standarddinge.entries) {

                          DatabaseService().updateStandarddinge(item.key.toString(), item.value as bool);

                          if (item.value == false) {
                            DatabaseService().updateShoppingItem(
                              item.key.toString(),
                              false,
                              1,
                            );
                          }
                        }

                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      child: Text('Aktualisieren'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: DatabaseService().getAllShoppingItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Keine Daten gefunden.'));
              }

              final shoppingData = snapshot.data!.data()!;

              return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: shoppingData.length + 1,
                itemBuilder: (context, index) {
                  if (index == shoppingData.length) {
                    return ElevatedButton(
                      onPressed: () async {
                       List<String> shoppedItems = shoppingData.entries
                            .where((item) => item.value['checked'] == true)
                            .map((item) => item.key.toString())
                            .toList();

                        List<String> standardItems = await DatabaseService().getAllStandarddinge().then((standarddinge) {
                          return standarddinge.keys.toList();
                        });

                        for (var itemName in shoppedItems) {
                          if (standardItems.contains(itemName)) {
                            DatabaseService().updateStandarddinge(itemName, true);
                          }
                          DatabaseService().deleteShoppingItem(itemName);
                        }
                      },
                      child: Text('Einkaufsliste leeren'),
                    );
                  }

                  final item = shoppingData.entries.elementAt(index);

                  return CheckboxListTile(
                    title: Text(item.key.toString()),
                    value: item.value['checked'] as bool,
                    onChanged: (value) {
                      setState(() {
                        DatabaseService().updateShoppingItem(
                          item.key.toString(),
                          value ?? false,
                          item.value['amount'] as int,
                        );
                      });
                    },
                  );
                },
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
                onPressed: () async {
                  await _showStandarddingeDialog();
                },
                tooltip: 'Standarddinge',
                child: const Icon(Icons.receipt_long, size: 40),
              ),
            ),
            SizedBox(
              width: 75,
              height: 75,
              child: FloatingActionButton(
                onPressed: () {
                  //_showAddTrackingDialog();
                },
                tooltip: 'Rezept hinzufügen',
                child: const Icon(Icons.menu_book, size: 40),
              ),
            ),
            SizedBox(
              width: 75,
              height: 75,
              child: FloatingActionButton(
                onPressed: () {
                  //_showAddTrackingDialog();
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
