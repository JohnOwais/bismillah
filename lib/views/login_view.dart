import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bismillah/views/home_view.dart';
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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 200,
              ),
              const SizedBox(height: 20),
              InputText(
                  hint: "Phone no.",
                  hideText: false,
                  prefixIcon: Icons.phone,
                  controller: usernameController,
                  valid: validUser,
                  errorMsg: "Can't be less than 10 characters",
                  inputType: TextInputType.number,
                  maxLength: 10),
              InputText(
                  hint: "Password",
                  hideText: true,
                  prefixIcon: Icons.lock,
                  controller: passwordController,
                  valid: validPass,
                  errorMsg: "Can't be less than 8 characters",
                  inputType: TextInputType.text,
                  maxLength: 50),
              LoginButton(
                userController: usernameController,
                passController: passwordController,
                user: validUser,
                pass: validPass,
                updateUserValidity: (bool isValid) {
                  setState(() {
                    validUser = isValid;
                  });
                },
                updatePasswordValidity: (bool isValid) {
                  setState(() {
                    validPass = isValid;
                  });
                },
                isLoading: isLoading,
                updateLoading: (bool loading) {
                  setState(() {
                    isLoading = loading;
                  });
                },
              ),
              const RegisterButton()
            ],
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
      child: Row(children: [
        Expanded(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterView()),
                      ((route) => false));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 194, 253)),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Register",
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ))),
      ]),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton(
      {super.key,
      required this.userController,
      required this.passController,
      required this.user,
      required this.pass,
      required this.updateUserValidity,
      required this.updatePasswordValidity,
      required this.isLoading,
      required this.updateLoading});

  final TextEditingController userController;
  final TextEditingController passController;
  final bool user;
  final bool pass;
  final Function(bool) updateUserValidity;
  final Function(bool) updatePasswordValidity;
  final bool isLoading;
  final Function(bool) updateLoading;

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseDatabase.instance.ref('Users');
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
      child: Row(children: [
        Expanded(
            child: ElevatedButton(
                onPressed: () async {
                  updateUserValidity(true);
                  updatePasswordValidity(true);
                  if (userController.text.length < 10) {
                    updateUserValidity(false);
                  } else if (passController.text.length < 8) {
                    updatePasswordValidity(false);
                  } else {
                    updateLoading(true);
                    String username = userController.text.toLowerCase().trim();
                    String enteredPassword = passController.text;
                    DataSnapshot? snapshot = (await query
                            .orderByChild('phone')
                            .equalTo(username)
                            .once())
                        .snapshot;
                    if (snapshot.value != null) {
                      Map<dynamic, dynamic>? userData =
                          snapshot.value as Map<dynamic, dynamic>?;
                      String storedPassword =
                          userData?.values.first['password'];
                      if (enteredPassword == storedPassword) {
                        Fluttertoast.showToast(
                            msg: "Login Success",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        updateLoading(false);
                        // ignore: use_build_context_synchronously
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
                            ((route) => false));
                      } else {
                        Fluttertoast.showToast(
                            msg: "Invalid Password",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        updateLoading(false);
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: "Phone Number Not Registered",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      updateLoading(false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 76, 150)),
                child: Padding(
                  padding: EdgeInsets.all(isLoading ? 8.5 : 16),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                ))),
      ]),
    );
  }
}

class InputText extends StatelessWidget {
  const InputText(
      {super.key,
      required this.hint,
      required this.hideText,
      required this.prefixIcon,
      required this.controller,
      required this.valid,
      required this.errorMsg,
      required this.inputType,
      required this.maxLength});

  final String hint;
  final bool hideText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool valid;
  final String errorMsg;
  final TextInputType inputType;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32.0, 16),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        obscureText: hideText,
        style: const TextStyle(color: Color.fromARGB(255, 0, 76, 150)),
        decoration: InputDecoration(
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 0, 76, 150))),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 0, 76, 150))),
            errorText: valid ? null : errorMsg,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(prefixIcon, color: Colors.blue)),
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
      ),
    );
  }
}
