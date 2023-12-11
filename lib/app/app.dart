import 'package:bismillah/views/login_view.dart';
import 'package:flutter/material.dart';

class Bismillah extends StatelessWidget {
  const Bismillah({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: "Bismillah", home: LoginView());
  }
}
