import 'package:astarte/pages/welcome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

void main(){
  runApp(ForgotPassword());
}

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  Config appConfiguration = new Config();
  final _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();


  void ForgotPassword()async{
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
        };

        var url = appConfiguration.apiBaseUrl + 'ForgotPassword.php';
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

        print(response.body);
        Fluttertoast.showToast(
            msg: "New password sent to your mobile number",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );


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
        title: "ForgotPassword",
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
                    child: Column(
                    children: [
                      Text("Forgotten your password?",style: TextStyle(fontFamily: "Lato_Black",fontSize: 30),),
                    Padding(
                        padding: EdgeInsets.all(20),
                                    child: Text("We will send you a new password once we verify your email or phone number",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 15),textAlign: TextAlign.center,))
                                ],
                              ),
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
                                      hintText: "Email or Username",
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
                              FlatButton(onPressed: (){
                                ForgotPassword();
                              },
                                  child: Text("Get new password",style: TextStyle(color: Colors.white,fontFamily: "Lato_Bold"),),color: Colors.blue,minWidth: double.infinity,height: 50,shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: Colors.blue)
                                  ))

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
