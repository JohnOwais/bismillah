import 'package:bismillah/views/home_view.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Bismillah",
        theme: ThemeData(
          primarySwatch: Colors.blue
        ),
        home: const HomeView()
    );
  }
}