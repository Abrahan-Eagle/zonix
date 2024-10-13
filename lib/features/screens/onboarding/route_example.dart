import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';

class RouteExample extends StatefulWidget {
    const RouteExample({super.key});

  @override
  RouteExampleState createState() => RouteExampleState();
}

class RouteExampleState extends State<RouteExample> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Page1(),
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
//      appBar: AppBar(title: Text("Page 1")),
      body: Center(
        child: MaterialButton(
          child: const Text("Next"),
          onPressed: () {
            Navigator.push(context, ConcentricPageRoute(builder: (ctx) {
              return const Page2();
            }));
          },
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
//      appBar: AppBar(title: Text("Page 2")),
      body: Center(
        child: MaterialButton(
          child: const Text("Back"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}