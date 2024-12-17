import 'package:flutter/material.dart';

import 'cartoon_page.dart';
import 'recordings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAIN assessment demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'MAIN Assessment'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.lightGreen,
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageCarousel()),
                );
              },
              child: Text("Assessment"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  // foregroundColor: Colors.lightGreen,
                  fixedSize: Size(300, 60),
                  textStyle: TextStyle(fontSize: 30),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.lightGreen, width: 5),
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordedFilesPage()),
                );
              },
              child: Text("Score"),
              style: ElevatedButton.styleFrom(
                  // maximumSize: Size(400, 60),
                  backgroundColor: Colors.white,
                  // foregroundColor: Colors.lightGreen,
                  fixedSize: Size(300, 60),
                  textStyle: TextStyle(fontSize: 30),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.lightGreen, width: 5),
                    borderRadius: BorderRadius.circular(10),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
