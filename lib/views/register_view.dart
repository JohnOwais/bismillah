// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, empty_catches

import 'package:bismillah/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();
  final valid = [true, true, true, true, true, true, true];
  bool isLoading = false;
  final phoneFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginView()),
              ((route) => false));
        },
        child: Scaffold(
          appBar: AppBar(
              title: const Text(
                "User Registration",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
              iconTheme: const IconThemeData(color: Colors.white),
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Color.fromARGB(30, 0, 0, 0),
              )),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InputText(
                    hint: "Name",
                    icon: Icons.person,
                    hideText: false,
                    errorMsg: "Can't be less than 3 characters",
                    keyboard: TextInputType.name,
                    controller: nameController,
                    valid: valid[0],
                    maxLength: 30,
                  ),
                  InputText(
                    hint: "State",
                    icon: Icons.location_city,
                    hideText: false,
                    errorMsg: "Please select state",
                    keyboard: TextInputType.text,
                    controller: stateController,
                    valid: valid[1],
                    maxLength: 20,
                  ),
                  InputText(
                    hint: "Town/City",
                    icon: Icons.home,
                    hideText: false,
                    errorMsg: "Please select city/town",
                    keyboard: TextInputType.text,
                    controller: cityController,
                    valid: valid[2],
                    maxLength: 20,
                  ),
                  InputText(
                    hint: "Address",
                    icon: Icons.location_on,
                    hideText: false,
                    errorMsg: "Can't be less than 5 characters",
                    keyboard: TextInputType.streetAddress,
                    controller: addressController,
                    valid: valid[3],
                    maxLength: 30,
                  ),
                  InputText(
                    hint: "Phone No.",
                    icon: Icons.phone,
                    hideText: false,
                    errorMsg: "Invalid phone no.",
                    keyboard: TextInputType.number,
                    controller: phoneController,
                    valid: valid[4],
                    maxLength: 10,
                    focusNode: phoneFocusNode,
                  ),
                  InputText(
                    hint: "Password",
                    icon: Icons.lock_open,
                    hideText: true,
                    errorMsg: "Can't be less than 8 characters",
                    keyboard: TextInputType.visiblePassword,
                    controller: passwordController,
                    valid: valid[5],
                    maxLength: 50,
                  ),
                  InputText(
                    hint: "Comfirm Password",
                    icon: Icons.lock,
                    hideText: true,
                    errorMsg: "Can't be less than 8 characters",
                    keyboard: TextInputType.visiblePassword,
                    controller: confirmPassController,
                    valid: valid[6],
                    maxLength: 50,
                  ),
                  RegisterButton(
                    name: nameController,
                    state: stateController,
                    city: cityController,
                    address: addressController,
                    phone: phoneController,
                    password: passwordController,
                    confirmPass: confirmPassController,
                    updateNameValidity: (bool isValid) {
                      setState(() {
                        valid[0] = isValid;
                      });
                    },
                    updateStateValidity: (bool isValid) {
                      setState(() {
                        valid[1] = isValid;
                      });
                    },
                    updateCityValidity: (bool isValid) {
                      setState(() {
                        valid[2] = isValid;
                      });
                    },
                    updateAddressValidity: (bool isValid) {
                      setState(() {
                        valid[3] = isValid;
                      });
                    },
                    updatePhoneValidity: (bool isValid) {
                      setState(() {
                        valid[4] = isValid;
                      });
                    },
                    updatePasswordValidity: (bool isValid) {
                      setState(() {
                        valid[5] = isValid;
                      });
                    },
                    updateConfirmPassValidity: (bool isValid) {
                      setState(() {
                        valid[6] = isValid;
                      });
                    },
                    isLoading: isLoading,
                    updateLoading: (bool loading) {
                      setState(() {
                        isLoading = loading;
                      });
                    },
                    phoneFocusNode: phoneFocusNode,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton(
      {super.key,
      required this.name,
      required this.state,
      required this.city,
      required this.address,
      required this.phone,
      required this.password,
      required this.confirmPass,
      required this.updateNameValidity,
      required this.updateStateValidity,
      required this.updateCityValidity,
      required this.updateAddressValidity,
      required this.updatePhoneValidity,
      required this.updatePasswordValidity,
      required this.updateConfirmPassValidity,
      required this.isLoading,
      required this.updateLoading,
      required this.phoneFocusNode});

  final TextEditingController name;
  final TextEditingController state;
  final TextEditingController city;
  final TextEditingController address;
  final TextEditingController phone;
  final TextEditingController password;
  final TextEditingController confirmPass;
  final Function(bool) updateNameValidity;
  final Function(bool) updateStateValidity;
  final Function(bool) updateCityValidity;
  final Function(bool) updateAddressValidity;
  final Function(bool) updatePhoneValidity;
  final Function(bool) updatePasswordValidity;
  final Function(bool) updateConfirmPassValidity;
  final bool isLoading;
  final Function(bool) updateLoading;
  final FocusNode phoneFocusNode;

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
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                onPressed: () async {
                  updateNameValidity(true);
                  updateStateValidity(true);
                  updateCityValidity(true);
                  updateAddressValidity(true);
                  updatePhoneValidity(true);
                  updatePasswordValidity(true);
                  updateConfirmPassValidity(true);
                  name.text = name.text.trim();
                  if (name.text.length < 3) {
                    updateNameValidity(false);
                  } else if (state.text.isEmpty) {
                    updateStateValidity(false);
                  } else if (city.text.isEmpty) {
                    updateCityValidity(false);
                  } else if (address.text.length < 5) {
                    updateAddressValidity(false);
                  } else if (phone.text.length < 10) {
                    updatePhoneValidity(false);
                  } else if (password.text.length < 8) {
                    updatePasswordValidity(false);
                  } else if (confirmPass.text.length < 8) {
                    updateConfirmPassValidity(false);
                  } else if (password.text != confirmPass.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          "Password doesn't match with Confirm Password",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.red));
                  } else {
                    updateLoading(true);
                    DataSnapshot? snapshot = (await query
                            .orderByChild('phone')
                            .equalTo(phone.text)
                            .once())
                        .snapshot;
                    if (snapshot.value == null) {
                      try {
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: '+91${phone.text}',
                          verificationCompleted:
                              (PhoneAuthCredential credential) async {
                            registerUser(
                                context,
                                name.text,
                                state.text,
                                city.text,
                                address.text,
                                phone.text,
                                password.text);
                          },
                          verificationFailed: (FirebaseAuthException e) {},
                          codeSent: (String verificationId, int? resendToken) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtpVerificationScreen(
                                    verificationId: verificationId,
                                    name: name.text,
                                    state: state.text,
                                    city: city.text,
                                    address: address.text,
                                    phone: phone.text,
                                    password: password.text),
                              ),
                            );
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text(
                                      "OTP Expired !!!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.red));
                          },
                          timeout: const Duration(seconds: 60),
                        );
                        updateLoading(false);
                      } catch (e) {}
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                            "Phone Number Already Registered",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.red));
                      updateLoading(false);
                      phone.text = "";
                      await Future.delayed(const Duration(seconds: 4));
                      FocusScope.of(context).requestFocus(phoneFocusNode);
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
                          "Register",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                )),
          ),
        ],
      ),
    );
  }
}

void registerUser(BuildContext context, String name, String state, String city,
    String address, String phone, String password) async {
  Map<String, String> user = {
    'name': name,
    'state': state,
    'city': city,
    'address': address,
    'phone': phone,
    'password': password
  };
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref('Users');
  await databaseReference.push().set(user);
  Fluttertoast.showToast(
      msg: "Registered Successfully",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginView()),
    ((route) => false),
  );
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen(
      {super.key,
      required this.verificationId,
      required this.name,
      required this.state,
      required this.city,
      required this.address,
      required this.phone,
      required this.password});

  final String verificationId;
  final String name;
  final String state;
  final String city;
  final String address;
  final String phone;
  final String password;

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
              "Enter the OTP sent to ${widget.phone}",
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
                    registerUser(
                        context,
                        widget.name,
                        widget.state,
                        widget.city,
                        widget.address,
                        widget.phone,
                        widget.password);
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

class InputText extends StatelessWidget {
  const InputText(
      {super.key,
      required this.hint,
      required this.icon,
      required this.hideText,
      required this.errorMsg,
      required this.keyboard,
      required this.controller,
      required this.valid,
      required this.maxLength,
      this.focusNode});

  final String hint;
  final IconData icon;
  final bool hideText;
  final String errorMsg;
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
        style: const TextStyle(color: Color.fromARGB(255, 0, 76, 150)),
        obscureText: hideText,
        decoration: InputDecoration(
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 0, 76, 150))),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 0, 76, 150))),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            errorText: valid ? null : errorMsg,
            prefixIcon: Icon(icon, color: Colors.blue)),
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        focusNode: focusNode,
      ),
    );
  }
}
