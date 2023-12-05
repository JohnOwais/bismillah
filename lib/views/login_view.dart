import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bismillah/home.dart';
import 'package:bismillah/views/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool validUser = true;
  bool validPass = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(
            'assets/logo.png',
            height: 200,
          ),
          const SizedBox(height: 20),
          InputText(hint: "Username", hideText: false, prefixIcon: Icons.person, controller: usernameController, valid: validUser, errorMsg: "Can't be less than 5 characters"),
          InputText(hint: "Password", hideText: true, prefixIcon: Icons.lock, controller: passwordController, valid: validPass, errorMsg: "Can't be less than 8 characters"),
          LoginButton(userController: usernameController, passController: passwordController, user: validUser, pass: validPass, updateUserValidity: (bool isValid) { setState(() { validUser = isValid;}); }, updatePasswordValidity: (bool isValid) { setState(() { validPass = isValid;}); }),
          const RegisterButton()
        ],
      ),
    );
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30,8,30,8),
      child: Row( children: [Expanded(
        child: ElevatedButton(onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const RegisterView()),
            ((route) => false)
          );
        }, style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 0, 194, 253)
        ), child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Register", style: TextStyle(
            fontSize: 15,
            color: Colors.black
          ),),
        ))),]
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.userController,
    required this.passController,
    required this.user,
    required this.pass,
    required this.updateUserValidity,
    required this.updatePasswordValidity
  });

  final TextEditingController userController;
  final TextEditingController passController;
  final bool user;
  final bool pass;
  final Function(bool) updateUserValidity;
  final Function(bool) updatePasswordValidity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30,8,30,8),
      child: Row(children: [Expanded(
        child:
      ElevatedButton(
        onPressed: () {
          updateUserValidity(true);
          updatePasswordValidity(true);
          if(userController.text.length < 5 && passController.text.length < 8) {
            updateUserValidity(false);
            updatePasswordValidity(false);
          } else if (userController.text.length < 5) {
            updateUserValidity(false);
          } else if (passController.text.length < 8) {
            updatePasswordValidity(false);
          } else {
            if(userController.text.toLowerCase() == "owais" && passController.text == "00000000") {
              Fluttertoast.showToast(
                msg: "Login Success",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
              );
              Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              ((route) => false)
              );
            } else {
              Fluttertoast.showToast(
                msg: "Invalid Login Credentials",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
              );
            }
          }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 0, 76, 150)
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Login", style: TextStyle(
          fontSize: 15,
          color: Colors.white
        ),),
      ))),
      ]),
    );
  }
}

class InputText extends StatelessWidget {
  const InputText({
    super.key,
    required this.hint,
    required this.hideText, 
    required this.prefixIcon,
    required this.controller,
    required this.valid,
    required this.errorMsg
  });

  final String hint;
  final bool hideText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool valid;
  final String errorMsg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32,0,32.0,16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        obscureText: hideText,
        style: const TextStyle(
          color: Color.fromARGB(255, 0, 76, 150)),
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 76, 150))
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 76, 150))
          ),
          errorText: valid? null : errorMsg,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey
          ),
          prefixIcon: Icon(prefixIcon, color: Colors.blue)
        ),
      ),
    );
  }
}