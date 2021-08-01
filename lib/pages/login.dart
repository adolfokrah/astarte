import 'package:astarte/pages/blockedPage.dart';
import 'package:astarte/pages/welcome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import 'forgotPassword.dart';

void main(){
  runApp(Login());
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Config appConfiguration = new Config();
  final _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  var visible = true;
  var blocked = false;

  void login()async{
      if(_formKey.currentState.validate()){
          try{
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: new CircularProgressIndicator(),
                        ),
                        new Text("Please wait..."),
                      ],
                    ),
                  ),
                );
              },
            );

            var data = {
              'id': username.text,
              'password': password.text
            };

            var url = appConfiguration.apiBaseUrl + 'login.php';
            var response = await http.post(url, body: data);

            Navigator.of(context,rootNavigator: true).pop();

            if(response.body == '0'){
              Fluttertoast.showToast(
                  msg: "Sorry! you provided the wrong credentials.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              return;
            }

            if(response.body == '1'){
              Navigator.pushReplacement(context, PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: BlockedPage()));
              return;
            }

            // print(response.body); return;
            SharedPreferences storage = await SharedPreferences.getInstance();
            storage.setString("userDetails", response.body);

            // print(response.body);
            Phoenix.rebirth(context);

          }catch(e){
            print(e);
          }
      }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        title: "Login",
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            brightness: Brightness.light,
            leading: IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.black),onPressed: (){
              Navigator.pop(context);
            },),
          ),
          body: Column(
            children: [
              Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      Center(
                        child: Text("Login",style: TextStyle(fontFamily: "Lato_Black",fontSize: 30),),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 20,bottom:20),
                              child: TextFormField(
                                controller: username,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(15),
                                fillColor: Colors.black12,
                                filled: true,
                                hintText: "Email",
                                hintStyle: TextStyle(fontFamily: "Lato_Regular",fontSize: 15.0),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black26, width: 0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    )
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black26, width: 0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    )
                                )
                          ),
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your phone number or email';
                                  }
                                  // if(RegExp(r"^[a-zZ-A]+").matchAsPrefix(value)){
                                  //   return "done";
                                  // }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10,bottom:20),
                              child: TextFormField(
                                controller: password,
                                obscureText: visible,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(15),
                                    fillColor: Colors.black12,
                                    filled: true,
                                    hintText: "Password",
                                    hintStyle: TextStyle(fontFamily: "Lato_Regular",fontSize: 15.0),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black26, width: 0),
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        )
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black26, width: 0),
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        )
                                    ),
                                    suffixIcon: IconButton(icon:Icon(visible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,color: Colors.black26,),onPressed: (){
                                      setState(() {
                                        visible = !visible;
                                      });
                                    },)
                                ),
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            FlatButton(onPressed: (){
                              login();
                            },
                                child: Text("Login",style: TextStyle(color: Colors.white,fontFamily: "Lato_Bold"),),color: Colors.blue,minWidth: double.infinity,height: 50,shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.blue)
                            )),
                            Padding(
                              padding: EdgeInsets.only(top: 20,bottom: 20),
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ForgotPassword()));
                                },
                                child: Center(
                                  child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text:"Forgot your login details?",
                                            style: TextStyle(
                                                fontFamily: "Lato_Bold",
                                                color: Colors.black87,
                                                fontSize: 14)),
                                        TextSpan(
                                            text: "  Get help here",
                                            style: TextStyle(
                                                fontFamily: "Lato_Black",
                                                color: Color(0xff0468c5),
                                                fontSize: 14))
                                      ])),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: Divider(thickness: 1.5,)),
                                SizedBox(
                                  width: 40,
                                  child: Center(child: Text("OR",style: TextStyle(color:Colors.black38),),),
                                ),
                                Flexible(child: Divider(thickness: 1.5,))
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: FlatButton(onPressed: (){},
                                  child: Row(
                                    children: [
                                      Padding(padding: EdgeInsets.only(right: 20),
                                      child: FaIcon(FontAwesomeIcons.facebook,color: Colors.white,),),
                                      Text("Login with Facebook",style: TextStyle(color: Colors.white,fontFamily: "Lato_Bold"),)
                                    ],
                                  ),color: Colors.blueAccent,minWidth: double.infinity,height: 50,shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: Colors.blueAccent)
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: FlatButton(onPressed: (){},
                                  child: Row(
                                    children: [
                                      Padding(padding: EdgeInsets.only(right: 20),
                                        child: FaIcon(FontAwesomeIcons.google,color: Colors.white,),),
                                      Text("Login with Google",style: TextStyle(color: Colors.white,fontFamily: "Lato_Bold"),)
                                    ],
                                  ),color: Colors.redAccent,minWidth: double.infinity,height: 50,shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: Colors.redAccent)
                                  )),
                            )

                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 70,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12, width: 1)),
                color: Colors.white,
              ),
              child: InkWell(
                onTap: (){
                  Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rightToLeft, child: Welcome()));
                },
                child: Center(
                  child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text:"Don't have an account?",
                            style: TextStyle(
                                fontFamily: "Lato_Bold",
                                color: Colors.black87,
                                fontSize: 14)),
                        TextSpan(
                            text: "  Sign up",
                            style: TextStyle(
                                fontFamily: "Lato_Black",
                                color: Color(0xff0468c5),
                                fontSize: 14))
                      ])),
                ),
              ),
            )],
          ),
        )
    );
  }
}
