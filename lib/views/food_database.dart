import 'package:flutter/material.dart';

import '../utility.dart';

class FoodDatabase extends StatefulWidget {
  const FoodDatabase({super.key});

  @override
  State<FoodDatabase> createState() => _FoodDatabaseState();
}

class _FoodDatabaseState extends State<FoodDatabase> {

  void _showAddFoodDialog() {
    String name = '';
    String calories = '';
    String protein = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Neues Lebensmittel hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) => calories = value,
                decoration: InputDecoration(labelText: 'Kalorien'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                onChanged: (value) => protein = value,
                decoration: InputDecoration(labelText: 'Protein'),
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
              onPressed: () {
                final foodItem = FoodItem(
                  name: name,
                  calories: int.parse(calories),
                  protein: int.parse(protein),
                );
                DatabaseService().addFoodItem(foodItem);
                Navigator.pop(context);
              },
              child: Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Anzahl der Tabs
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          //title: const Text("TabBar Beispiel"),
          bottom: const TabBar(
            labelPadding: EdgeInsets.symmetric(horizontal: 12.0),
            tabs: [
              Tab(text: "Lebensmittel"),
              Tab(text: "Rezepte"),
              Tab(text: "Tracking"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder(
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
                  return ListTile(
                    title: Text(docs[index].id),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kalorien: ${docs[index].data()['calories']}'),
                        Text('Protein: ${docs[index].data()['protein']}'),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          
            StreamBuilder(
            stream: DatabaseService().getAllRecipeItems(),
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
                  return ListTile(
                    title: Text(docs[index].id),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kalorien: ${docs[index].data()['calories']}'),
                        Text('Protein: ${docs[index].data()['protein']}'),
                      ],
                    ),
                  );
                },
              );
            },
          ),
            StreamBuilder(
            stream: DatabaseService().getAllTrackingItems(),
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
                  return ListTile(
                    title: Text(docs[index].id),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kalorien: ${docs[index].data()['calories']}'),
                        Text('Protein: ${docs[index].data()['protein']}'),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          ],
        ),
      ),
    );
  }
    /*
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
                  return ListTile(
                    title: Text(docs[index].id),
                    
                  );
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
              onPressed: () {_showAddFoodDialog();},
              tooltip: 'Neu hinzufügen',
              child: const Icon(Icons.add, size: 40),
            ),
          ),
        ),
      ],
    ); 
  }*/
}
