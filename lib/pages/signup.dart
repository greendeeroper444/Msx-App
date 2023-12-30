import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:msx_app/pages/signin.dart';

import '../auths/auth.dart';
import '../components/buttons.dart';
import '../components/textfields.dart';
import '../helpers/displaymessagetouser.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailOrMobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  void signUpUser() async{
    showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ));

    if(passwordController.text != confirmController.text){
      Navigator.pop(context);
      displayMessageToUser("Password don't match", context);
    }else{
      try {
        UserCredential? userCredential;

        if (emailOrMobileController.text.contains('@')){
          userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
              email: emailOrMobileController.text,
              password: passwordController.text);
        }else{
          userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
              email: emailOrMobileController.text + "@msx.com",
              password: passwordController.text);
          // TODO: Implement phone number verification
        }

        String username = await createUserDocument(userCredential);

        Navigator.pop(context);

        Fluttertoast.showToast(
          msg: "Welcome to MSX, @$username",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.7),
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AuthPage()));
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        displayMessageToUser(e.code, context);
      }
    }
  }

  //for firestore
  Future<String> createUserDocument(UserCredential? userCredential) async{
    if (userCredential != null && userCredential.user != null) {
      String username = usernameController.text;

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'username': username,
      });

      return username;
    }

    return '';
  }


  //checkbox
  bool checkTheBoxAgree = false;
  bool checkTheBoxAccept = false;
  bool isButtonEnabled = false;

  check(){
    setState(() {
      checkTheBoxAgree = !checkTheBoxAgree;
      checkButtonStatus();
    });
  }

  check2(){
    setState(() {
      checkTheBoxAccept = !checkTheBoxAccept;
      checkButtonStatus();
    });
  }

  bool canSignUp() {
    return checkTheBoxAgree && checkTheBoxAccept;
  }

  void checkButtonStatus() {
    setState(() {
      isButtonEnabled = checkTheBoxAgree && checkTheBoxAccept;

    });
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

              const SizedBox(height: 50,),

              const Center(
                child: Text(
                  "Create an account!",
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white
                  ),
                ),
              ),

              const SizedBox(height: 40,),

              MyTextField(
                hintText: "Username",
                icon: Icons.person,
                controller: usernameController,
              ),

              const SizedBox(height: 20,),

              MyTextField(
                hintText: "Email or Mobile Number",
                icon: Icons.alternate_email,
                controller: emailOrMobileController,
              ),

              const SizedBox(height: 20,),

              MyTextField(
                hintText: "Password",
                obscureText: true,
                icon: Icons.lock,
                controller: passwordController,

              ),

              const SizedBox(height: 20,),

              MyTextField(
                hintText: "Confirm Password",
                obscureText: true,
                icon: Icons.lock,
                controller: confirmController,

              ),

              const SizedBox(height: 12,),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
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
                            value: checkTheBoxAgree,
                            onChanged: (value) {
                              check();
                            },
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: " I agree to MSX ",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "Terms of Use",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/term_of_use');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.grey.shade500,
                          ),
                          child: Checkbox(
                            checkColor: Colors.white,
                            value: checkTheBoxAccept,
                            onChanged: (value) {
                              check2();
                            },
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: " I accept MSX ",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/privacy_policy');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              MyButton(
                customColor: const Color.fromARGB(255, 148, 87, 235),
                text: "Sign Up",
                onTap: canSignUp() ? signUpUser : null,
                isButtonEnabled: canSignUp(),
              ),

              const SizedBox(height: 20,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),

                  const SizedBox(width: 20,),

                  GestureDetector(
                    onTap: (){
                      Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => SigninPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign In",
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
