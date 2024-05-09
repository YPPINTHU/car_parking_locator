import 'package:car_parking_locator/user_credentials/signin_screen.dart';
import 'package:flutter/material.dart';
import '../reusable/reusable_methods.dart';
import '../reusable/reusable_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';
  String otp = '';
  String token = '';
  bool isCodeSent = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(248, 215, 58, 1.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/car_for_login.png"),
                const SizedBox(
                  height: 10,
                ),
                textField("Name", Icons.person_outline, false, _nameController),
                const SizedBox(
                  height: 30,
                ),
                textField("Phone", Icons.lock_outline, true, _mobileController),
                const SizedBox(
                  height: 20,
                ),
                textField(
                    "Email", Icons.person_outline, false, _emailController),
                const SizedBox(
                  height: 30,
                ),
                textField(
                    "Password", Icons.lock_outline, true, _passwordController),
                const SizedBox(
                  height: 20,
                ),
                textField("Confirm Password", Icons.lock_outline, true,
                    _confirmPassController),
                const SizedBox(
                  height: 20,
                ),
                reusableButton(context, false, () {
                  if (_nameController.text.isNotEmpty &&
                      _mobileController.text.isNotEmpty &&
                      _emailController.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty &&
                      _confirmPassController.text.isNotEmpty) {
                    if (_passwordController.text ==
                        _confirmPassController.text) {
                      verifyPhoneNumber(_mobileController.text);
                      // await _verifyOTP();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              shadowColor: Colors.black,
                              elevation: 8,
                              content: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                    height: 400,
                                    width: 450,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        imgContainer(
                                            'assets/images/otp_verify_img.png',
                                            200,
                                            200),
                                        // if (isCodeSent)
                                        TextField(
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(
                                              Icons.verified_outlined,
                                              color: Colors.black,
                                            ),
                                            labelText: "Enter OTP",
                                            labelStyle: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.9)),
                                            filled: true,
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                                borderSide: const BorderSide(
                                                    width: 0,
                                                    style: BorderStyle.none)),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            otp = value;
                                          },
                                          cursorColor: Colors.black87,
                                          style: TextStyle(
                                              color: Colors.black87
                                                  .withOpacity(0.9),
                                              fontSize: 16),
                                        ),

                                        const SizedBox(height: 30),
                                        // if (isCodeSent)
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith(
                                                              (states) {
                                                    if (states.contains(
                                                        MaterialState
                                                            .pressed)) {
                                                      return Colors.black26;
                                                    }
                                                    return Colors.white;
                                                  }),
                                                  shape:
                                                      MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    (30))),
                                                  )),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                await _verifyOTP();
                                              },
                                              child: const Text(
                                                "VERIFY OTP",
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              )),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      showErrorAlert(context,
                          'Password and Confirm password not Matched ');
                    }
                  } else {
                    // showErrorAlert(context, 'Please Fill the All fields ');
                  }
                }),
                signInOption(),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    verified(AuthCredential authResult) {}

    verificationFailed(authException) {
      print('Verification failed: $authException');
      if (authException.toString() ==
          "[firebase_auth/too-many-requests] We have blocked all requests from this device due to unusual activity. Try again later.") {
        showInformation(context,
            "Looks like you've made several attempts. Take a short break and try again later. Thank you!");
      } else {
        showInformation(context,
            "Apologies for the inconvenience. Please attempt again later.");
      }
    }

    codeSent(String verificationId, [int? forceResendingToken]) {
      setState(() {
        this.verificationId = verificationId;
        this.isCodeSent = true;
      });
    }

    codeAutoRetrievalTimeout(String verificationId) {
      print('Verification timeout: $verificationId');
      showToast("Verification timeout,try again.");
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: '+94 $phoneNumber',
      timeout: const Duration(seconds: 60),
      verificationCompleted: verified,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  void _insertUserData(String name, String email, String mobile, String id) {
    Map<String, dynamic> data = {
      'id': id,
      'userName': name,
      'phoneNo': mobile,
      'email': email,
    };
    _database.child('users').push().set(data).then((_) {
      print('User data inserted');
    }).catchError((error) {
      print('User data insertion failed');
    });
  }

  Future<void> _verifyOTP() async {
    try {
      final AuthCredential phoneCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(phoneCredential);
      final User? user = userCredential.user;

      if (user != null) {
        final AuthCredential emailCredential =
            await EmailAuthProvider.credential(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await user.linkWithCredential(emailCredential);

        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text)
            .then((value) {
          _insertUserData(_nameController.text, _emailController.text,
              _mobileController.text, FirebaseAuth.instance.currentUser!.uid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        }).catchError((error) {
          if (error is FirebaseAuthException) {
            if (error.code == 'email-already-in-use') {
              showInformation(context,
                  'The email address is already in use by another account.');
            } else {
              print("Try again");
            }
          }
        });
      } else {
        print('User is null');
      }
    } catch (e) {
      print("Error: $e");
      if (e is FirebaseAuthException && e.code == 'provider-already-linked') {
        showInformation(
            context, "The email address is already in use by another account.");
      } else {
        showInformation(context, "An error occurred: $e");
      }
    }
  }

  Row signInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Back to", style: TextStyle(color: Colors.black87)),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigation(context, const SignInScreen());
          },
          child: const Text(
            " Sign IN",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
