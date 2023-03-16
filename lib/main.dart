import 'package:flutter/material.dart';

import 'app.dart';
import 'models/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static late Oo8Fractal fractal;
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Oo8Fractal app;

  @override
  void initState() {
    MyApp.fractal = app = Oo8Fractal();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XC8',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(),
      ),

      //make text white

      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Oo8App(app),
    );
  }
}
