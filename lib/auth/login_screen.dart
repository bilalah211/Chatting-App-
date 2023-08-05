import 'package:connect/api/apis.dart';
import 'package:connect/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../components/utils/Utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  googleSignInMethod() {
    Utils.showProgressBar(context);
    signInWithGoogle().then((value) async {
      Navigator.pop(context);
      if (value != null) {
        print('\nUser: ${value.user}');
        print('\nUserAdditionalInfo: ${value.additionalUserInfo}');
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
            return HomeScreen();
          }));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      Utils.snackBar(context,
          'Something Went Wrong Please Check Your Internet Connection');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Welcome to Connect',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.normal, letterSpacing: 2),
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              right: _isAnimated ? width * 0.30 : -width * 0.4,
              top: height * 0.15,
              width: width * 0.4,
              duration: Duration(seconds: 1),
              child: Image.asset('images/chat.png')),
          Positioned(
            left: width * 0.15,
            width: width * .7,
            bottom: height * .20,
            height: height * 0.07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.black26, width: 1)),
              onPressed: () {
                googleSignInMethod();
              },
              icon: Image.asset(
                'images/google.png',
                height: height * 0.04,
              ),
              label: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(text: '  Signin with '),
                    TextSpan(
                      text: 'Google',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
