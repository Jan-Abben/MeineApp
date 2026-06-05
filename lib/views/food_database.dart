import 'package:flutter/material.dart';

import '../utility.dart';

class FoodDatabase extends StatefulWidget {
  const FoodDatabase({super.key});

  @override
  State<FoodDatabase> createState() => _FoodDatabaseState();
}

class _FoodDatabaseState extends State<FoodDatabase> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: StreamBuilder(
            stream: DatabaseService().getAllFoodItems(),
            builder: (context, snapshot) {
              
              if (snapshot.hasError) {
                return Text('Fehler');
              }
          
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
          
              final docs = snapshot.data!.docs;
          
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(docs[index].id));
                },
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
              onPressed: () {},
              tooltip: 'Neu hinzufügen',
              child: const Icon(Icons.add, size: 40),
            ),
          ),
        ),
      ],
    );
  }
}
