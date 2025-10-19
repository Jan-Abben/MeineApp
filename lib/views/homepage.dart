import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 50,
                children: <Widget>[
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: FloatingActionButton(
                    onPressed: (){},
                    tooltip: 'Ernährung',
                    child: const Icon(Icons.local_dining,size: 100,),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: FloatingActionButton(
                    onPressed: (){},
                    tooltip: 'Einkaufen',
                    child: const Icon(Icons.local_grocery_store,size: 100,),
                    ),
                  ),
                ],
              );
  }
}