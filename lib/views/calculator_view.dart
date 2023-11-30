import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  int firstNumber = 0, secondNumber = 0;
  num result = 0;
  final displayOneController = TextEditingController();
  final displayTwoController = TextEditingController();
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    _listener = AppLifecycleListener(
      onShow: _onShow,
      onHide: _onHide,
      onResume: _onResume,
      onDetach: _onDetach,
      onInactive: _onInactive,
      onPause: _onPause,
      onRestart: _onRestart,
      onStateChange: _onStateChange
    );
    super.initState();
  }

  void _onShow() => print("onShow Called");
  void _onHide() => print("onHide Called");
  void _onResume() => print("onResume Called");
  void _onDetach() => print("onDetach Called");
  void _onInactive() => print("onInactive Called");
  void _onPause() => print("onPause Called");
  void _onRestart() => print("onRestart Called");
  void _onStateChange(AppLifecycleState state) {
    print("onStateChange with state $state");
  }

  @override
  void dispose() {
    displayOneController.dispose();
    displayTwoController.dispose();
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Display(hint: "Enter first number", controller: displayOneController),
          const SizedBox(height: 30),
          Display(hint: "Enter second number", controller: displayTwoController),
          const SizedBox(height: 30),
          Text(result.toString(), style: const TextStyle(
            fontSize: 70,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    result = num.tryParse(displayOneController.text)! + num.tryParse(displayTwoController.text)!;
                  });
                },
                child: const Icon(CupertinoIcons.add),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    result = num.tryParse(displayOneController.text)! - num.tryParse(displayTwoController.text)!;
                  });
                },
                child: const Icon(CupertinoIcons.minus),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    result = num.tryParse(displayOneController.text)! * num.tryParse(displayTwoController.text)!;
                  });
                },
                child: const Icon(CupertinoIcons.multiply),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    result = num.tryParse(displayOneController.text)! / num.tryParse(displayTwoController.text)!;
                    result = double.parse(result.toStringAsFixed(2));
                  });
                },
                child: const Icon(CupertinoIcons.divide),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    result = firstNumber = secondNumber = 0;
                    displayOneController.clear();
                    displayTwoController.clear();
                  });
                },
                label: const Text("Clear"),
              ),
            ],
            )
        ],
      ),
    );
  }
}

class Display extends StatelessWidget {
  const Display({
    super.key,
    this.hint = "Enter a number",
    required this.controller
  });
  final String? hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      autofocus: true,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10)
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10)
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white
        ),
      ),
    );
  }
}