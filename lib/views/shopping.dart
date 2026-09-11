import 'package:flutter/material.dart';
import '../utility.dart';

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
          itemCount: shoppingData.length,
          itemBuilder: (context, index) {
            final item = shoppingData.entries.elementAt(index);
            return CheckboxListTile(
              title: Text(item.key.toString()),
              value: item.value['abgehakt'] as bool,
              onChanged: (value) {
                setState(() {
                  DatabaseService().updateShoppingItem(item.key.toString(), value ?? false);
                });
              },
            );
          },
        );
      },
    );
  }
}