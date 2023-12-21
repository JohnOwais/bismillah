// ignore_for_file: use_build_context_synchronously

import 'package:bismillah/views/login_view.dart';
import 'package:bismillah/views/password_view.dart';
import 'package:bismillah/views/prifile_view.dart';
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
  String selectedValue = '1';

  Future<bool?> _showLogoutConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

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
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          backgroundColor: Colors.green,
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color.fromARGB(30, 0, 0, 0),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (String value) async {
                if (value == '1') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfileView(phone: phoneNumber)));
                } else if (value == '2') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PasswordView(phone: phoneNumber)));
                } else {
                  bool confirmLogout =
                      await _showLogoutConfirmationDialog() as bool;
                  if (confirmLogout) {
                    Fluttertoast.showToast(
                        msg: "Logged Out",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginView()),
                        ((route) => false));
                  } else {
                    Fluttertoast.showToast(
                        msg: "Cancelled",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                }
                setState(() {
                  selectedValue = value;
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: '1',
                  child: Row(
                    children: [
                      Icon(Icons.account_circle, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Edit Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: '2',
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Change Password'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: '3',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
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
