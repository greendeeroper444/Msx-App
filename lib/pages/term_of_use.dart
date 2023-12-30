import 'package:flutter/material.dart';


class TermOfUsePage extends StatelessWidget {
  const TermOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Use",
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              "Welcome to MSX Terms of Use",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12),

            Text(
              "Effective Date: January 1, 2025",
              style: TextStyle(
                  fontSize: 16,
              ),
            ),
            SizedBox(height: 16),

            Text(
              "Introduction",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            Text(
              "Thank you for choosing MSX app! These Terms of Use outline the rules and regulations for using our service.",
              style: TextStyle(
                  fontSize: 16,
              ),
            ),

            SizedBox(height: 16),

            Text(
              "1. Acceptance of Terms",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "By accessing or using MSX app, you agree to comply with and be bound by these Terms of Use. If you do not agree to these terms, please do not use the app.",
              style: TextStyle(
                  fontSize: 16,
              ),
            ),

           SizedBox(height: 16),

            Text(
              "2. User Responsibilities",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "You are responsible for providing accurate and up-to-date information during registration. Prohibited activities include unauthorized access, abuse, or any illegal actions.",
              style: TextStyle(
                  fontSize: 16,
              ),
            ),
            // Add more sections as needed
          ],
        ),
      ),
    );
  }
}