import 'dart:ui';

import '../screens/map.dart';
import 'reset_password_screen.dart';
import 'package:flutter/material.dart';
import '../reusable/reusable_methods.dart';
import '../reusable/reusable_widgets.dart';
import 'signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(248, 215, 58, 1.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.1, 20, 20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  logoWidget("assets/images/car_for_login.png"),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).size.height * 0.01, 20, 0),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Sign in',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              color: Colors.white),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        textField("Email", Icons.person_outline, false,
                            _emailController),
                        const SizedBox(
                          height: 30,
                        ),
                        textField("Password", Icons.lock_outline, true,
                            _passwordController),
                        const SizedBox(
                          height: 20,
                        ),
                        reusableButton(context, true, () {
                          if (_emailController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty) {
                            FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text)
                                .then((value) {
                              Navigation(context, CarParkingMap());
                            }).onError((error, stackTrace) {
                              if (error.toString() ==
                                  "[firebase_auth/user-disabled] The user account has been disabled by an administrator.") {
                                showToast("Your account has been blocked.");
                              } else {
                                showErrorAlert(context,
                                    'Username or Password is incorrect please try again.');
                              }

                              print("Error ${error}");
                            });
                          } else {
                            showErrorAlert(
                                context, 'Please Fill the All fields ');
                          }
                        }),
                        signUpOption(),
                        forgetPasswordOption(),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.black87)),
        GestureDetector(
          onTap: () {
            Navigation(context, const SignUpScreen());
          },
          child: const Text(
            " Sign Up",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Row forgetPasswordOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigation(context, ResetPasswordScreen());
          },
          child: const Text(
            "Forget Password",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
