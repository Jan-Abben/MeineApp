import 'package:flutter/material.dart';
import 'package:meine_app/views/homepage.dart';
import 'package:meine_app/views/food_tracking.dart';
import 'package:meine_app/views/shopping.dart';
import 'package:meine_app/views/food_database.dart';

//Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

//Hilfsklassen und Methoden
class PageItem {
  final String title;
  final Widget page;
  final IconData icon;

  const PageItem({required this.title, required this.page, required this.icon});
}

/* Roadmap:

Lebensmitteldatenbank aufbauen:
- Lebensmittel/Gericht hinzufügen

Einkaufen:
- Einkaufslisten erstellen
  - Lebensmittel/Gericht hinzufügen
  - Mengenangaben hinzufügen

- Einkaufliste ansehen
  -Dinge von der Liste abhaken
  -Einkaufliste löschen (eventuell langfristig speichern?)


Food Tracking:
- Lebensmittel/Gericht bei einem Tag hinzufügen
- Nährwerte berechnen lassen
- vergleich mit Zielvorgaben
- Alles langfristig speichern (Verlauf anzeigen)





*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Firebase initialized!!!");

  final db = FirebaseFirestore.instance;

  await db.collection("Lebensmittelverfolgung").get().then((event) {
    for (var doc in event.docs) {
      print("${doc.id} => ${doc.data()}");
    }
  });

  await db.collection("Lebensmittelverfolgung").doc("test").get().then((doc) {
    if (doc.exists) {
      print("Document data: ${doc.data()}");
    } else {
      print("No such document!");
    }
  });

  print("Read success!!!");

  runApp(const MyApp());
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

  final pages = [
    PageItem(
      title: 'Startseite', 
      icon: Icons.home, 
      page: const HomePage()
      ),
    PageItem(
      title: 'Lebensmittelverfolgung',
      icon: Icons.local_dining,
      page: const FoodTracking(),
    ),
    PageItem(
      title: 'Einkaufen',
      icon: Icons.local_grocery_store,
      page: const Shopping(),
    ),
    PageItem(
      title: 'Datenbanken',
      icon: Icons.storage,
      page: const FoodDatabase(),
    ),
  ];

  int selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    Widget page = pages[selectedIndex].page;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(pages[selectedIndex].title)),
      ),
      body: Row(
        spacing: 0,
        children: [
          SafeArea(
            child: NavigationRail(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              extended: false,
              destinations: pages.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.title),
                );
              }).toList(),
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),

          //Page switches to the selected page in the Destination Rail
          Expanded(child: page),
        ],
      ),
    );
  }
}
