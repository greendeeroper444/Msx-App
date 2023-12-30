import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Color customColor;
  final String text;
  final void Function()? onTap;
  final bool isButtonEnabled;

  const MyButton({
    super.key,
    required this.customColor,
    required this.text,
    required this.onTap,
    required this.isButtonEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isButtonEnabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isButtonEnabled ? customColor : customColor.withOpacity(0.10),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}

class SigninSignupButton extends StatelessWidget {
  final Color customColor;
  final String text;
  final void Function()? onTap;

  const SigninSignupButton({
    super.key,
    required this.customColor,
    required this.text,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 70),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: customColor
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}

