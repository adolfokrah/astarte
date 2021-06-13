import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config.dart';

void main(){
  runApp(BlockedPage());
}

class BlockedPage extends StatefulWidget {
  @override
  _BlockedPageState createState() => _BlockedPageState();
}

class _BlockedPageState extends State<BlockedPage> {
  Config appConfiguration = new Config();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: appConfiguration.appColor),
      title: "Login",
      home: Scaffold(
      appBar: AppBar(
          // leading: IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.black),onPressed: (){
          //   Navigator.pop(context);
          // },),
          backgroundColor: Colors.white,
          elevation: 0,
          brightness: Brightness.light,
        ),
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                Icon(CupertinoIcons.lock, size: 200, color: Colors.black12,),
                Padding(
                  padding: const EdgeInsets.only(left: 60.0,right: 60.0, top: 50),
                  child: Text("Your account is currently blocked for some reason.",style: TextStyle(fontFamily: "Lato_Black",fontSize: 17),textAlign: TextAlign.center,),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("Please contact our support team for assistance. Thank you.",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 14),textAlign: TextAlign.center,),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
