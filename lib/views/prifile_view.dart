// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.phone});

  final String phone;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final nameController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final valid = [
    true,
    true,
    true,
    true,
  ];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData(phone: widget.phone);
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = widget.phone;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
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
                hint: "Name",
                icon: Icons.person,
                errorMsg: "Can't be less than 3 characters",
                keyboard: TextInputType.name,
                controller: nameController,
                valid: valid[0],
                maxLength: 30,
              ),
              InputText(
                hint: "State",
                icon: Icons.location_city,
                errorMsg: "Please select state",
                keyboard: TextInputType.text,
                controller: stateController,
                valid: valid[1],
                maxLength: 20,
              ),
              InputText(
                hint: "Town/City",
                icon: Icons.home,
                errorMsg: "Please select city/town",
                keyboard: TextInputType.text,
                controller: cityController,
                valid: valid[2],
                maxLength: 20,
              ),
              InputText(
                hint: "Address",
                icon: Icons.location_on,
                errorMsg: "Can't be less than 5 characters",
                keyboard: TextInputType.streetAddress,
                controller: addressController,
                valid: valid[3],
                maxLength: 30,
              ),
              UpdateButton(
                  name: nameController,
                  state: stateController,
                  city: cityController,
                  address: addressController,
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
                  isLoading: isLoading,
                  updateLoading: (bool loading) {
                    setState(() {
                      isLoading = loading;
                    });
                  },
                  phone: phoneNumber),
            ],
          ),
        ),
      ),
    );
  }

  void fetchUserData({required String phone}) async {
    Query query = FirebaseDatabase.instance.ref('Users');
    DataSnapshot? snapshot =
        (await query.orderByChild('phone').equalTo(phone).once()).snapshot;
    Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
    setState(() {
      nameController.text = userData.values.first['name'];
      stateController.text = userData.values.first['state'];
      cityController.text = userData.values.first['city'];
      addressController.text = userData.values.first['address'];
    });
  }
}

class UpdateButton extends StatelessWidget {
  const UpdateButton(
      {super.key,
      required this.name,
      required this.state,
      required this.city,
      required this.address,
      required this.updateNameValidity,
      required this.updateStateValidity,
      required this.updateCityValidity,
      required this.updateAddressValidity,
      required this.isLoading,
      required this.updateLoading,
      required this.phone});

  final TextEditingController name;
  final TextEditingController state;
  final TextEditingController city;
  final TextEditingController address;
  final Function(bool) updateNameValidity;
  final Function(bool) updateStateValidity;
  final Function(bool) updateCityValidity;
  final Function(bool) updateAddressValidity;
  final bool isLoading;
  final Function(bool) updateLoading;
  final String phone;

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
                  updateNameValidity(true);
                  updateStateValidity(true);
                  updateCityValidity(true);
                  updateAddressValidity(true);
                  if (name.text.length < 3) {
                    updateNameValidity(false);
                  } else if (state.text.isEmpty) {
                    updateStateValidity(false);
                  } else if (city.text.isEmpty) {
                    updateCityValidity(false);
                  } else if (address.text.length < 5) {
                    updateAddressValidity(false);
                  } else {
                    updateLoading(true);
                    DataSnapshot? snapshot = (await query
                            .orderByChild('phone')
                            .equalTo(phone)
                            .once())
                        .snapshot;
                    Map<dynamic, dynamic> userData =
                        snapshot.value as Map<dynamic, dynamic>;
                    String userKey = userData.keys.first.toString();
                    DatabaseReference databaseReference =
                        query as DatabaseReference;
                    databaseReference.child(userKey).update({
                      'name': name.text,
                      'state': state.text,
                      'city': city.text,
                      'address': address.text,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          "Updated Successfully",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.green));
                    updateLoading(false);
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
      required this.errorMsg,
      required this.keyboard,
      required this.controller,
      required this.valid,
      required this.maxLength,
      this.focusNode});

  final String hint;
  final IconData icon;
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
        style: const TextStyle(color: Color.fromARGB(255, 0, 120, 50)),
        decoration: InputDecoration(
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green)),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            errorText: valid ? null : errorMsg,
            prefixIcon: Icon(icon, color: Colors.green)),
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        focusNode: focusNode,
      ),
    );
  }
}
