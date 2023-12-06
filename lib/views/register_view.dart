import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              InputText(hint: "Name", icon: Icons.person, hideText: false, errorMsg: "Can't be less than 5 characters", keyboard: TextInputType.name),
              InputText(hint: "Address", icon: Icons.location_on, hideText: false, errorMsg: "Can't be less than 5 characters", keyboard: TextInputType.streetAddress),
              InputText(hint: "Town/City", icon: Icons.home, hideText: false, errorMsg: "Can't be less than 5 characters", keyboard: TextInputType.text),
              InputText(hint: "State", icon: Icons.location_city, hideText: false, errorMsg: "Can't be less than 5 characters", keyboard: TextInputType.text),
              InputText(hint: "Phone No.", icon: Icons.phone, hideText: false, errorMsg: "Can't be less than 5 characters", keyboard: TextInputType.number),
              InputText(hint: "Password", icon: Icons.lock_open, hideText: true, errorMsg: "Can't be less than 5 characters", keyboard: TextInputType.visiblePassword),
              InputText(hint: "Comfirm Password", icon: Icons.lock, hideText: true, errorMsg: "Can't be less than 5 characters", keyboard: TextInputType.visiblePassword),
              RegisterButton()
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
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 0, 76, 150)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              onPressed: () {

              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Register", style: TextStyle(
                  fontSize: 15,
                  color: Colors.white
                ),),
            )),
          ),
        ],
      ),
    );
  }
}

class InputText extends StatelessWidget {
  const InputText({
    super.key,
    required this.hint,
    required this.icon,
    required this.hideText,
    required this.errorMsg,
    required this.keyboard
  });

  final String hint;
  final IconData icon;
  final bool hideText;
  final String errorMsg;
  final TextInputType keyboard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8,8,8,0),
      child: TextField(
        keyboardType: keyboard,
        style: const TextStyle(
          color: Color.fromARGB(255, 0, 76, 150)
        ),
        obscureText: hideText,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 76, 150))
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 76, 150))
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey
          ),
          prefixIcon: Icon(icon, color: Colors.blue)
        ),
      ),
    );
  }
}