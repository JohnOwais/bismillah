import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.name, required this.phone});

  final String name;
  final String phone;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final String name = widget.name;
    final String phoneNumber = widget.phone;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(name: name, phone: phoneNumber)),
            ((route) => false)),
        Fluttertoast.showToast(
            msg: "Reloading...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0)
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(
              "Welcome $name",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Color.fromARGB(30, 0, 0, 0),
            )),
        body: const SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [],
            ),
          ),
        ),
      ),
    );
  }
}
