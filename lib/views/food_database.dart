import 'package:flutter/material.dart';

import '../utility.dart';

class FoodDatabase extends StatefulWidget {
  const FoodDatabase({super.key});

  @override
  State<FoodDatabase> createState() => _FoodDatabaseState();
}

class _FoodDatabaseState extends State<FoodDatabase>
    with SingleTickerProviderStateMixin {
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

  void _showAddRecipeDialog() {
    String name = '';
    List<IngredientInput> ingredients = [IngredientInput(), IngredientInput()];

    String calories = '';
    String protein = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, updateDialogState) {
            return AlertDialog(
              title: Text('Neues Rezept hinzufügen'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) => name = value,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),

                  ...List.generate(ingredients.length, (index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Zutat",
                            ),
                            onChanged: (value) {
                              ingredients[index].name = value;
                            },
                          ),
                        ),

                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Menge",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              ingredients[index].amount = value;
                            },
                          ),
                        ),
                      ],
                    );
                  }),

                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (ingredients.length < 9) {
                            updateDialogState(() {
                              ingredients.add(IngredientInput());
                            });
                          }
                        },
                        child: Text('Zutat hinzufügen'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (ingredients.isNotEmpty &&
                              ingredients.length > 1) {
                            updateDialogState(() {
                              ingredients.removeLast();
                            });
                          }
                        },
                        child: Text('Zutat entfernen'),
                      ),
                    ],
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
                    print(ingredients);
                    final recipeItem = RecipeItem(
                      name: name,
                      ingredients: {},
                      calories: int.parse(calories),
                      protein: int.parse(protein),
                    );
                    DatabaseService().addRecipeItem(recipeItem);
                    Navigator.pop(context);
                  },
                  child: Text('Hinzufügen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
              //title: const Text("TabBar Beispiel"),
              bottom: TabBar(
                controller: _tabController,
                labelPadding: EdgeInsets.symmetric(horizontal: 12.0),
                tabs: [
                  Tab(text: "Lebensmittel"),
                  Tab(text: "Rezepte"),
                  Tab(text: "Tracking"),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
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
                              Text(
                                'Kalorien: ${docs[index].data()['calories']}',
                              ),
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
                              Text(
                                'Kalorien: ${docs[index].data()['calories']}',
                              ),
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
                              Text(
                                'Kalorien: ${docs[index].data()['calories']}',
                              ),
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
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            width: 75,
            height: 75,
            child: FloatingActionButton(
              onPressed: () {
                final index = _tabController.index;

                switch (index) {
                  case 0:
                    _showAddFoodDialog();
                    // Aktion für Tab 1
                    break;
                  case 1:
                    _showAddRecipeDialog();
                    // Aktion für Tab 2
                    break;
                  case 2:
                    print("Add Tracking");
                    // Aktion für Tab 3
                    break;
                }
              },
              tooltip: 'Neu hinzufügen',
              child: const Icon(Icons.add, size: 40),
            ),
          ),
        ),
      ],
    );
  }

  //
}
