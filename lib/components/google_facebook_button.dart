import 'package:flutter/material.dart';

class GoogleFacebookButton extends StatelessWidget {

  final String imagePath;
  final Function()? onTap;

  const GoogleFacebookButton({
    super.key,
    required this.imagePath,required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[900],
        ),
        child: Image.asset(
          imagePath,
          height: 30,
        ),
      ),
    );
  }
}