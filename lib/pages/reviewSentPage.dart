import 'package:astarte/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(ReviewSentPage());
}

class ReviewSentPage extends StatefulWidget {
  @override
  _ReviewSentPageState createState() => _ReviewSentPageState();
}

class _ReviewSentPageState extends State<ReviewSentPage> {
  Config appConfiguration = new Config();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        title: "Send Feedback",
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              brightness: Brightness.light,
              centerTitle: false,
              leading: IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.black),onPressed: (){
                Navigator.pop(context);
              },),
            ),
            body: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(child: Icon(CupertinoIcons.paperplane_fill,size: 170,color: Colors.green,)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: Text("Review Sent", style: TextStyle(fontFamily: "Lato_Bold",fontSize: 20))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Center(child: Text("Thanks for your review", style: TextStyle(fontFamily: "Lato_Regular",fontSize: 20))),
                  )
                ],
              ),
            )
        ));
  }
}
