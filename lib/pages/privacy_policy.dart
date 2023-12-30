import 'package:flutter/material.dart';


class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Privacy Policy",
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
              "Our MSX Privacy Policy",
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
              "Overview",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Protecting your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our MSX App.",
              style: TextStyle(
                  fontSize: 16,
              ),
            ),

            SizedBox(height: 16),

            Text(
              "1. Information We Collect",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              "We collect information you provide directly to us, such as your name, email address, and preferences. We may also collect information automatically when you use our app.",
              style: TextStyle(
                  fontSize: 16,
              ),
            ),

            SizedBox(height: 16),

            Text(
              "2. Data Usage",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),

            SizedBox(height: 8),

            Text(
              "We use collected data to improve our services and personalize your experience. Your data is handled securely, and we do not sell or rent it to third parties.",
              style: TextStyle(
                  fontSize: 16,
              ),
            ),

            SizedBox(height: 16),

            Text(
              "3. Third-Party Services",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Our app may use third-party services or analytics tools. Please review their privacy policies for information on how they handle your data.",
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
