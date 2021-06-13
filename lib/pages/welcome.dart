import 'package:astarte/pages/login.dart';
import 'package:astarte/pages/signupPages/customerSignUp.dart';
import 'package:astarte/pages/signupPages/fashionDesignerSignUp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../config.dart';

void main(){
  runApp(Welcome());
}

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  Config appConfiguration = new Config();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Astarte',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/welcome.jpg"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            leading: IconButton(
                icon: Icon(
                   CupertinoIcons.back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                }),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10,bottom: 10,left:10),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Text("WELCOME TO",style: TextStyle(fontFamily: "Lato_Black",color: Colors.black,fontSize: 25),),
                        decoration: BoxDecoration(
                          color: Color(0xffffd6c9)
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10,left:10),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Text("ASTARTE",style: TextStyle(fontFamily: "Lato_Black",color: Colors.black,fontSize: 25),),
                        decoration: BoxDecoration(
                            color: Color(0xffffd6c9)
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text("SIGN UP AS A", style: TextStyle(color: Colors.white,fontFamily: "Lato_Black"),),
                      ),
                    ),
                    FlatButton(onPressed: (){
                      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rightToLeft, child: CustomerSignUp()));
                    },
                         color: Colors.white,
                         minWidth: double.infinity,
                         height: 45,
                        child: Text("CUSTOMER",style: TextStyle(fontFamily: "Lato_Black",fontSize: 15),)
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: FlatButton(onPressed: (){
                        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rightToLeft, child: FashionDesignerSignUp()));
                      },
                          color: Colors.white,
                          minWidth: double.infinity,
                          height: 45,
                          child: Text("FASHION DESIGNER",style: TextStyle(fontFamily: "Lato_Black",fontSize: 15),)
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
