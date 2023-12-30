import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:msx_app/pages/privacy_policy.dart';
import 'package:msx_app/pages/signin.dart';
import 'package:msx_app/pages/signup.dart';
import 'package:msx_app/pages/term_of_use.dart';

import '../components/buttons.dart';
import 'Bottom_Navigation/home.dart';


class SigninSignUpPage extends StatefulWidget {
  const SigninSignUpPage({super.key});

  @override
  State<SigninSignUpPage> createState() => _SigninSignUpPageState();
}

class _SigninSignUpPageState extends State<SigninSignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(225, 19, 18, 18),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/msx_logo.png",
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),

                   Padding(
                    padding: const EdgeInsets.only(right: 150.0),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Feel",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          TextSpan(
                            text: "\nthe\nEnergy of\n",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          TextSpan(
                            text: "Music",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),

                  const SizedBox(height: 50),

                  SigninSignupButton(
                    customColor: Colors.white.withOpacity(0.7),
                    text: "Sign In",
                    onTap: () async {
                      if (FirebaseAuth.instance.currentUser != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SigninPage()),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  SigninSignupButton(
                    customColor: const Color.fromARGB(255, 148, 87, 235),
                    text: "Sign Up",
                    onTap: () async {
                      if (FirebaseAuth.instance.currentUser != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 150),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TermOfUsePage()),
                          );
                        },
                        child: const Text(
                          "Term of Use",
                          style: TextStyle(color: Color.fromARGB(255, 148, 87, 235), fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                          );
                        },
                        child: const Text(
                          "Privacy Policy",
                          style: TextStyle(color: Color.fromARGB(255, 148, 87, 235), fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
