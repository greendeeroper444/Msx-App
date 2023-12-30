import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final void Function()? onPressed;
  final bool obscureText;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    this.icon,
    this.onPressed,
    this.obscureText = false,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(225, 19, 18, 18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 148, 87, 235).withOpacity(0.2),
          width: 1.5,
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              obscureText: obscureText,
            ),
          ),
          if (onPressed != null)
            IconButton(
              onPressed: onPressed,
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade400,
              ),
            )
        ],
      ),
    );
  }
}


class MyTypingField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Widget? suffixIcon;

  const MyTypingField({
    Key? key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                width: 3,
                color: Color.fromARGB(255, 148, 87, 235)
            )
        ),
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
    );
  }
}