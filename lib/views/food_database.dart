import 'package:flutter/material.dart';
import '../utility.dart';

class FoodDatabase extends StatefulWidget {
  const FoodDatabase({super.key});

  @override
  State<FoodDatabase> createState() => _FoodDatabaseState();
}

class _FoodDatabaseState extends State<FoodDatabase>
    with SingleTickerProviderStateMixin {
  void _showAddFoodDialog({
    String name = '',
    String calories = '',
    String protein = '',
  }) {
    final nameController = TextEditingController(text: name);
    final caloriesController = TextEditingController(text: calories);
    final proteinController = TextEditingController(text: protein);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Lebensmittel hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                onChanged: (value) => name = value,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: caloriesController,
                onChanged: (value) => calories = value,
                decoration: InputDecoration(labelText: 'Kalorien'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: proteinController,
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
                if (name.isNotEmpty &&
                    calories.isNotEmpty &&
                    protein.isNotEmpty) {
                  final foodItem = FoodItem(
                    name: name,
                    calories: int.parse(calories),
                    protein: double.parse(protein.replaceAll(',', '.')),
                  );
                  DatabaseService().addFoodItem(foodItem);
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

  void _showAddRecipeDialog({
    String name = '',
    List<IngredientInput>? ingredientsInput,
  }) {
    TextEditingController nameController = TextEditingController(text: name);

    List<IngredientInput>? ingredients =
        ingredientsInput ?? [IngredientInput(), IngredientInput()];

    List<TextEditingController> ingredientNameControllers = ingredients.map((
      ingredient,
    ) {
      return TextEditingController(text: ingredient.name);
    }).toList();

    List<TextEditingController> ingredientAmountControllers = ingredients.map((
      ingredient,
    ) {
      return TextEditingController(text: ingredient.amount);
    }).toList();

    showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, updateDialogState) {
            return AlertDialog(
              title: Text('Rezept hinzufügen'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      onChanged: (value) => name = value,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),

                    ...List.generate(ingredients.length, (index) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ingredientNameControllers[index],
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
                              controller: ingredientAmountControllers[index],
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
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              if (ingredients.length < 7) {
                                updateDialogState(() {
                                  ingredients.add(IngredientInput());
                                  ingredientNameControllers.add(
                                    TextEditingController(),
                                  );
                                  ingredientAmountControllers.add(
                                    TextEditingController(),
                                  );
                                });
                              }
                            },
                            child: Text('Zutat hinzufügen'),
                          ),
                        ),
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              if (ingredients.isNotEmpty &&
                                  ingredients.length > 1) {
                                updateDialogState(() {
                                  ingredients.removeLast();
                                  ingredientNameControllers.removeLast();
                                  ingredientAmountControllers.removeLast();
                                });
                              }
                            },
                            child: Text('Zutat entfernen'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (name.isNotEmpty &&
                        (ingredients.every(
                          (obj) => obj.name.isNotEmpty && obj.amount.isNotEmpty,
                        ))) {
                      double caloriesSum = 0;
                      double proteinSum = 0;

                      for (var obj in ingredients) {
                        try {
                          final foodItem = await DatabaseService().getFoodItem(
                            obj.name,
                          );

                          caloriesSum +=
                              foodItem.calories *
                              double.parse(obj.amount.replaceAll(',', '.'));
                          proteinSum +=
                              foodItem.protein *
                              double.parse(obj.amount.replaceAll(',', '.'));
                        } catch (e) {
                          // Handle the case where the food item is not found

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Lebensmittel "${obj.name}" nicht gefunden.',
                              ),
                            ),
                          );
                          return; // Exit the function if a food item is not found
                        }
                      }

                      final recipeItem = RecipeItem(
                        name: name,
                        ingredients: {
                          for (var obj in ingredients)
                            obj.name: double.parse(
                              obj.amount.replaceAll(',', '.'),
                            ),
                        },
                        calories: (caloriesSum / 10).round() * 10,
                        protein: (proteinSum).round(),
                      );
                      DatabaseService().addRecipeItem(recipeItem);

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
                isScrollable: true,
                tabAlignment: TabAlignment.start,
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
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(docs[index].id),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        DatabaseService().deleteFoodItem(
                                          docs[index].id,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Text('Löschen'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showAddFoodDialog(
                                          name: docs[index].id,
                                          calories: docs[index]
                                              .data()['calories']
                                              .toString(),
                                          protein: docs[index]
                                              .data()['protein']
                                              .toString(),
                                        );
                                      },
                                      child: Text('Bearbeiten'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(docs[index].id),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Zutaten:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Mengen:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      ...(docs[index].data()['ingredients']
                                              as Map<String, dynamic>)
                                          .entries
                                          .map((entry) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(entry.key),
                                                Text(entry.value.toString()),
                                              ],
                                            );
                                          }),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        DatabaseService().deleteRecipeItem(
                                          docs[index].id,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Text('Löschen'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showAddRecipeDialog(
                                          name: docs[index].id,
                                          ingredientsInput:
                                              (docs[index].data()['ingredients']
                                                      as Map<String, dynamic>)
                                                  .entries
                                                  .map((entry) {
                                                    final ingredient =
                                                        IngredientInput();
                                                    ingredient.name = entry.key;
                                                    ingredient.amount = entry
                                                        .value
                                                        .toString();
                                                    return ingredient;
                                                  })
                                                  .toList(),
                                        );
                                      },
                                      child: Text('Bearbeiten'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(docs[index].id),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Essen:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Mengen:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      ...(docs[index].data()['food']
                                              as Map<String, dynamic>)
                                          .entries
                                          .map((entry) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(entry.key),
                                                Text(entry.value.toString()),
                                              ],
                                            );
                                          }),
                                    ],
                                  ),
                                  actions: [
                                    
                                  ],
                                );
                              },
                            );
                          },
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
                    //print("Add Tracking");
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
}
