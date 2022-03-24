import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MakePayment {
  MakePayment({
    this.ctx,
    this.price,
    this.email,
  });

  BuildContext ctx;
  int price;
  String email;

  PaystackPlugin paystack = PaystackPlugin();

  static const String PAYSTACK_KEY =
      "pk_test_f20664e7a437cafa5462924094c93ea82145e1d7";

  CollectionReference transaction =
      FirebaseFirestore.instance.collection('transactions');
  //reference

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  //getUi
  PaymentCard _getCardUI() {
    return PaymentCard(
      number: "4084084084084081",
      cvc: "408",
      expiryMonth: 02,
      expiryYear: 23,
    );
  }

  Future initializePlugin() async {
    await paystack.initialize(publicKey: PAYSTACK_KEY);
  }

  //Method Charging from card
  ChargeCardAndMakePayment() async {
    initializePlugin().then((_) async {
      Charge charge = Charge()
        ..currency = 'ZAR'
        ..amount = price * 100
        ..email = email
        ..reference = _getReference()
        ..card = _getCardUI();

      CheckoutResponse response = await paystack.checkout(
        ctx,
        charge: charge,
        method: CheckoutMethod.card,
        fullscreen: false,
        logo: FlutterLogo(
          size: 24,
        ),
      );

      print("Response $response");

      if (response.status == true) {
        print("Transaction Successful");

        String datetime = DateTime.now().toString();
        String cNum = _getCardUI().number;
        transaction.add({
          'cardNum': cNum,
          'email': email,
          'price': price,
          'date': datetime
        });
      } else {
        print("transaction failed");
      }
    });
  }
}
