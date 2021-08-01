import 'package:astarte/pages/homePage.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';

import 'config.dart';

void main()async{

  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(Phoenix(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  Config appConfiguration = new Config();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        home: LandingPage()
    );
  }
}


