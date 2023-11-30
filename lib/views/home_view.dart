import 'package:bismillah/views/calculator_view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
          body: SafeArea(
              child: CalculatorView()
          ),
        );
  }
}