import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:msx_app/pages/forgot_password.dart';
import 'package:msx_app/pages/signup.dart';

import '../auths/auth.dart';
import '../components/buttons.dart';
import '../components/google_facebook_button.dart';
import '../components/textfields.dart';
import '../helpers/displaymessagetouser.dart';
import '../services/authservice.dart';


class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  bool showPass = false;

  showPassword(){
    setState(() {
      showPass = !showPass;
    });
  }

  bool checkTheBox = false;

  check(){
    setState(() {
      checkTheBox = !checkTheBox;
    });
  }


  final TextEditingController emailOrMobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signInUser() async {
    showDialog(
      context: context,
      builder: (context) =>
      const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if(passwordController.text.isEmpty && emailOrMobileController.text.isEmpty){
      Navigator.pop(context);
      displayMessageToUser("Please enter both email/mobile and password", context);
    }else if(emailOrMobileController.text.isEmpty){
      Navigator.pop(context);
      displayMessageToUser("Please enter an email or mobile number", context);
    }else if(passwordController.text.isEmpty){
      Navigator.pop(context);
      displayMessageToUser("Please enter a password", context);
    }else{
      try {
        UserCredential? userCredential;

        if(emailOrMobileController.text.contains('@')){
          userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailOrMobileController.text,
            password: passwordController.text,
          );
        } else {
          userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailOrMobileController.text + "@msx.com",
            password: passwordController.text,
          );
          // TODO: Implement phone number verification
        }

        Navigator.pop(context);

        Fluttertoast.showToast(
          msg: "You are now logged in to MSX",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.7),
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthPage()),
        );
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        displayMessageToUser(e.code, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(225, 19, 18, 18),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 100,),

              const Center(
                child: Text(
                  "Welcome Back!",
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white
                  ),
                ),
              ),

              const SizedBox(height: 40,),

              MyTextField(
                  hintText: "Email or Mobile Number",
                  icon: Icons.alternate_email,
                  controller: emailOrMobileController
              ),

              const SizedBox(height: 20,),

              MyTextField(
                hintText: "Password",
                onPressed: showPassword,
                obscureText: showPass ? false : true,
                icon: Icons.lock,
                controller: passwordController,
              ),

              const SizedBox(height: 12,),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.grey.shade500,
                          ),
                          child: Checkbox(
                            checkColor: Colors.white,
                            value: checkTheBox ?  true :  false,
                            onChanged: (value){
                              check();
                            },
                          ),
                        ),
                        const Text(
                          "Remember me",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        )
                      ],
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color.fromARGB(255, 148, 87, 235),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              MyButton(
                  customColor: const Color.fromARGB(255, 148, 87, 235),
                  text: "Sign In",
                  onTap: signInUser,
                  isButtonEnabled: true,
              ),

              const SizedBox(height: 20,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(thickness: 0.5, color: Colors.grey[500]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Or Sign In With', style: TextStyle(color: Colors.grey[700])),
                    ),
                    Expanded(
                      child: Divider(thickness: 0.5, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  GoogleFacebookButton(
                      onTap: () => signInWithGoogle(context),
                      imagePath: 'assets/google.png'
                  ),

                  const SizedBox(width: 20,),

                  GoogleFacebookButton(
                      onTap: () => signInWithFacebook(context),
                      imagePath: 'assets/facebook.png'
                  ),
                ],
              ),

              const SizedBox(height: 20,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),

                  const SizedBox(width: 20,),

                  GestureDetector(
                    onTap: (){
                      Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => SignupPage()
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Color.fromARGB(255, 148, 87, 235),
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],

              )
            ],
          ),
        ),
      ),
    );
  }
}
