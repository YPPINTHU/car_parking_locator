import 'dart:ui';
import 'package:car_parking_locator/user_credentials/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../reusable/reusable_methods.dart';
import '../reusable/reusable_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Reset Password",
          style: TextStyle(
              fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Color.fromRGBO(248, 215, 58, 1.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Column(
                children: [
                  logoWidget("assets/images/reset.png"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              color: Colors.white),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        textField("Email", Icons.email_outlined, false,
                            _emailController),
                        const SizedBox(
                          height: 30,
                        ),
                        resetButton(context, () async {
                          if (_emailController.text.isNotEmpty) {
                            try {
                              var userCheck = await FirebaseAuth.instance
                                  // ignore: deprecated_member_use
                                  .fetchSignInMethodsForEmail(
                                      _emailController.text);
                              if (userCheck.isEmpty) {
                                showErrorAlert(context,
                                    'No user found with this email address.');
                              } else {
                                // Send password reset email
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                        email: _emailController.text);
                                showInformationAlert(
                                  context,
                                  'Password reset email sent. Check your inbox.',
                                  SignInScreen(),
                                );
                              }
                            } catch (e) {
                              showErrorAlert(context, 'An error occurred: $e');
                            }
                          } else {
                            showErrorAlert(
                                context, 'please enter your email address');
                          }
                        }),
                        const SizedBox(
                          height: 10,
                        )
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

  Container resetButton(BuildContext context, Function onTap) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.black26;
              }
              return Colors.white;
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular((30))),
            )),
        child: const Text(
          "RESET",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
