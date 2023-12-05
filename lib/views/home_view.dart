import 'package:bismillah/views/login_view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
          body: SafeArea(
              child: LoginView()
          ),
        );
  }
}