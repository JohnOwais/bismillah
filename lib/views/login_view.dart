// ignore_for_file: use_build_context_synchronously, empty_catches, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
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
      appBar: AppBar(
          toolbarHeight: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color.fromARGB(50, 0, 0, 0),
          )),
      backgroundColor: Colors.white,
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
              const RegisterButton(),
              const SizedBox(height: 20),
              const LoginUsingOTP()
            ],
          ),
        ),
      ),
    );
  }
}

class LoginUsingOTP extends StatefulWidget {
  const LoginUsingOTP({
    super.key,
  });

  @override
  State<LoginUsingOTP> createState() => _LoginUsingOTPState();
}

class _LoginUsingOTPState extends State<LoginUsingOTP> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Forgot passward? "),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const OtpDialog();
              },
            );
          },
          child: const Text(
            "Login using OTP",
            style: TextStyle(
                color: Color.fromARGB(255, 0, 76, 150),
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class OtpDialog extends StatefulWidget {
  const OtpDialog({
    super.key,
  });

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final phoneController = TextEditingController();
  bool validPhone = true;
  bool isOtpLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              OtpTextField(textController: phoneController, valid: validPhone),
              OtpButton(
                textController: phoneController,
                isLoading: isOtpLoading,
                updateOTPValidity: (bool isValid) {
                  setState(() {
                    validPhone = isValid;
                  });
                },
                updateOTPLoading: (bool isValid) {
                  setState(() {
                    isOtpLoading = isValid;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OtpButton extends StatelessWidget {
  const OtpButton({
    super.key,
    required this.textController,
    required this.isLoading,
    required this.updateOTPValidity,
    required this.updateOTPLoading,
  });

  final TextEditingController textController;
  final bool isLoading;
  final Function(bool) updateOTPValidity;
  final Function(bool) updateOTPLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: ElevatedButton(
        onPressed: () async {
          updateOTPValidity(true);
          if (textController.text.length < 10) {
            updateOTPValidity(false);
          } else {
            updateOTPLoading(true);
            Query query = FirebaseDatabase.instance.ref('Users');
            DataSnapshot? snapshot = (await query
                    .orderByChild('phone')
                    .equalTo(textController.text)
                    .once())
                .snapshot;
            if (snapshot.value != null) {
              Map<dynamic, dynamic> userData =
                  snapshot.value as Map<dynamic, dynamic>;
              String name = userData.values.first['name'];
              try {
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: '+91${textController.text}',
                  verificationCompleted:
                      (PhoneAuthCredential credential) async {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                name: name, phone: textController.text)),
                        ((route) => false));
                  },
                  verificationFailed: (FirebaseAuthException e) {},
                  codeSent: (String verificationId, int? resendToken) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpVerificationScreen(
                          verificationId: verificationId,
                          phoneNumber: textController.text,
                        ),
                      ),
                    );
                  },
                  codeAutoRetrievalTimeout: (String verificationId) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          "OTP Expired !!!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.red));
                  },
                  timeout: const Duration(seconds: 60),
                );
                updateOTPLoading(false);
              } catch (e) {}
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "Phone Number Not Registered",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.red));
              updateOTPLoading(false);
            }
          }
        },
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: const Color.fromARGB(255, 0, 76, 150)),
        child: Padding(
          padding: EdgeInsets.all(isLoading ? 8.5 : 16),
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text(
                  "Get OTP",
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }
}

class OtpTextField extends StatelessWidget {
  const OtpTextField({
    super.key,
    required this.textController,
    required this.valid,
  });

  final TextEditingController textController;
  final bool valid;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      keyboardType: TextInputType.number,
      maxLength: 10,
      decoration: InputDecoration(
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          hintText: "Phone no.",
          errorText: valid ? null : "Can't be less than 10 digits"),
      style: const TextStyle(color: Color.fromARGB(255, 0, 76, 150)),
    );
  }
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen(
      {super.key, required this.verificationId, required this.phoneNumber});

  final String verificationId;
  final String phoneNumber;

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool valid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP Verification"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the OTP sent to ${widget.phoneNumber}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                  labelText: "OTP",
                  border: const OutlineInputBorder(),
                  errorText: valid ? null : "Can't be less than 6 digits"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String smsCode = otpController.text.trim();
                setState(() {
                  valid = true;
                });
                if (otpController.text.length < 6) {
                  setState(() {
                    valid = false;
                  });
                } else {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationId,
                    smsCode: smsCode,
                  );
                  try {
                    await FirebaseAuth.instance
                        .signInWithCredential(credential);
                    Query query = FirebaseDatabase.instance.ref('Users');
                    DataSnapshot? snapshot = (await query
                            .orderByChild('phone')
                            .equalTo(widget.phoneNumber)
                            .once())
                        .snapshot;
                    Map<dynamic, dynamic> userData =
                        snapshot.value as Map<dynamic, dynamic>;
                    String name = userData.values.first['name'];
                    String passkey = userData.values.first['password'];
                    Fluttertoast.showToast(
                        msg: "Login Success",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                name: name,
                                phone: widget.phoneNumber,
                                pass: passkey)),
                        ((route) => false));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          "Invalid OTP",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.red));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text(
                "Verify OTP",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterView()),
                  );
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
      child: Row(
        children: [
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
                      String username = userController.text;
                      String enteredPassword = passController.text;
                      DataSnapshot? snapshot = (await query
                              .orderByChild('phone')
                              .equalTo(username)
                              .once())
                          .snapshot;
                      if (snapshot.value != null) {
                        Map<dynamic, dynamic> userData =
                            snapshot.value as Map<dynamic, dynamic>;
                        String name = userData.values.first['name'];
                        String storedPassword =
                            userData.values.first['password'];
                        if (enteredPassword == storedPassword) {
                          Fluttertoast.showToast(
                              msg: "Login Success",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          updateLoading(false);
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(name: name, phone: username)),
                              ((route) => false));
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text(
                                    "Invalid Password",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.red));
                          updateLoading(false);
                        }
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text(
                                  "Phone Number Not Registered",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: Colors.red));
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
        ],
      ),
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
