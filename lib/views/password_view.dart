// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class PasswordView extends StatefulWidget {
  const PasswordView({super.key, required this.phone});

  final String phone;

  @override
  State<PasswordView> createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  final valid = [
    true,
    true,
    true,
  ];
  bool isLoading = false;
  final passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final phoneNumber = widget.phone;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(30, 0, 0, 0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              InputText(
                hint: "Old password",
                icon: Icons.lock,
                keyboard: TextInputType.name,
                controller: oldPassController,
                valid: valid[0],
                maxLength: 30,
                focusNode: passwordFocusNode,
              ),
              InputText(
                hint: "New password",
                icon: Icons.lock_open,
                keyboard: TextInputType.text,
                controller: newPassController,
                valid: valid[1],
                maxLength: 20,
              ),
              InputText(
                hint: "Confirm new password",
                icon: Icons.lock_open,
                keyboard: TextInputType.text,
                controller: confirmPassController,
                valid: valid[2],
                maxLength: 20,
              ),
              UpdateButton(
                  oldPass: oldPassController,
                  newPass: newPassController,
                  confirmPass: confirmPassController,
                  updateOldPassValidity: (bool isValid) {
                    setState(() {
                      valid[0] = isValid;
                    });
                  },
                  updateNewPassValidity: (bool isValid) {
                    setState(() {
                      valid[1] = isValid;
                    });
                  },
                  updateConfirmPassValidity: (bool isValid) {
                    setState(() {
                      valid[2] = isValid;
                    });
                  },
                  isLoading: isLoading,
                  updateLoading: (bool loading) {
                    setState(() {
                      isLoading = loading;
                    });
                  },
                  phone: phoneNumber,
                  oldPasswordFocusNode: passwordFocusNode),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateButton extends StatelessWidget {
  const UpdateButton(
      {super.key,
      required this.oldPass,
      required this.newPass,
      required this.confirmPass,
      required this.updateOldPassValidity,
      required this.updateNewPassValidity,
      required this.updateConfirmPassValidity,
      required this.isLoading,
      required this.updateLoading,
      required this.phone,
      required this.oldPasswordFocusNode});

  final TextEditingController oldPass;
  final TextEditingController newPass;
  final TextEditingController confirmPass;
  final Function(bool) updateOldPassValidity;
  final Function(bool) updateNewPassValidity;
  final Function(bool) updateConfirmPassValidity;
  final bool isLoading;
  final Function(bool) updateLoading;
  final String phone;
  final FocusNode oldPasswordFocusNode;

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseDatabase.instance.ref('Users');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                onPressed: () async {
                  updateOldPassValidity(true);
                  updateNewPassValidity(true);
                  updateConfirmPassValidity(true);
                  if (oldPass.text.length < 8) {
                    updateOldPassValidity(false);
                  } else if (newPass.text.length < 8) {
                    updateNewPassValidity(false);
                  } else if (confirmPass.text.length < 8) {
                    updateConfirmPassValidity(false);
                  } else if (newPass.text != confirmPass.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          "New Password doesn't match with Confirm Password",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.red));
                  } else {
                    updateLoading(true);
                    DataSnapshot? snapshot = (await query
                            .orderByChild('phone')
                            .equalTo(phone)
                            .once())
                        .snapshot;
                    Map<dynamic, dynamic> userData =
                        snapshot.value as Map<dynamic, dynamic>;
                    String oldPassword = userData.values.first['password'];
                    if (oldPass.text == oldPassword) {
                      String userKey = userData.keys.first.toString();
                      DatabaseReference databaseReference =
                          query as DatabaseReference;
                      databaseReference.child(userKey).update({
                        'password': newPass.text,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                            "Updated Successfully",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.green));
                      updateLoading(false);
                      oldPass.text = "";
                      newPass.text = "";
                      confirmPass.text = "";
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                            "Invalid Old Password",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.red));
                      updateLoading(false);
                      await Future.delayed(const Duration(seconds: 4));
                      FocusScope.of(context).requestFocus(oldPasswordFocusNode);
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(isLoading ? 8.5 : 16),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Update",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                )),
          ),
        ],
      ),
    );
  }
}

class InputText extends StatelessWidget {
  const InputText(
      {super.key,
      required this.hint,
      required this.icon,
      required this.keyboard,
      required this.controller,
      required this.valid,
      required this.maxLength,
      this.focusNode});

  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final TextEditingController controller;
  final bool valid;
  final int maxLength;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Color.fromARGB(255, 0, 120, 50)),
        obscureText: true,
        decoration: InputDecoration(
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green)),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            errorText: valid ? null : "Can't be less than 8 characters",
            prefixIcon: Icon(icon, color: Colors.green)),
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        focusNode: focusNode,
      ),
    );
  }
}
