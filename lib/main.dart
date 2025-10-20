import 'package:flutter/material.dart';
import 'package:meine_app/views/homepage.dart';
import 'package:meine_app/views/meal_plan.dart';
import 'package:meine_app/views/shopping.dart';


import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';


import 'package:flutter/services.dart' show rootBundle;
import 'package:meine_app/csv_handling.dart' as csv_handling;

void main() {
  runApp(const MyApp());
  csv_handling.main();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meine App',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const CurrentPage(title: 'Startseite'),
    );
  }
  

}

class CurrentPage extends StatefulWidget {
  const CurrentPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<CurrentPage> createState() => _CurrentPageState();
}

class _CurrentPageState extends State<CurrentPage> {
  
  Future<void> load_assets() async {
    final rawData = await rootBundle.loadString('assets/data/sample.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
    

    csv_handling.writeCsvFile('Example.csv', csvTable);
  }

  var selectedIndex = 0;

   @override
  void initState() {
    super.initState();

    load_assets();
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = MealPlan();
        break;
      case 2:
        page = Shopping();
        break;
      default:
        page = Text("Seite nicht gefunden");
        print("Error: no page found");
    }


    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(widget.title)),
      ),
      body: Row(
        spacing: 0,
        children: [
          SafeArea(
            child: NavigationRail(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home), 
                  label: Text('Startseite')
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.local_dining), 
                  label: Text('Ernährung')
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.local_grocery_store,), 
                  label: Text('Einkaufen')
                )
              ], 
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              )
            ),
        
          //Page switches to the selected page in the Destination Rail
          Expanded(
            child: page
          ),
        ],
      ),
    );
  }
}


