import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';

class Utils {
  static void snackBar(context, String message) {
    showFlushbar(
      context: (context),
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.decelerate,
        animationDuration: const Duration(seconds: 3),
        backgroundColor: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(18),
        message: message,
        messageColor: Colors.black,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.black),
      )..show(context),
    );
  }

  static void showProgressBar(context) {
    showDialog(
        context: context,
        builder: (_) => Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ));
  }
}
