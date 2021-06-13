import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';
import '../config.dart';

void main(){
  runApp(ChangePassword());
}

class ChangePassword extends StatefulWidget {
  final userDetails;

  ChangePassword({Key key, @required this.userDetails}) : super(key: key);
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  Config appConfiguration = new Config();
  final _formKey = GlobalKey<FormState>();
  TextEditingController newPassword = TextEditingController();
  TextEditingController oldPassword = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  void processForm()async{
    try{

      if(_formKey.currentState.validate()){


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
                    new Text("updating password..."),
                  ],
                ),
              ),
            );
          },
        );


        var data = widget.userDetails;
        data['password'] = md5.convert(utf8.encode(newPassword.text)).toString();
        data['photoPath'] = '';
        var url = appConfiguration.apiBaseUrl + 'updateUserProfile.php';
        var response = await http.post(url, body:data);

        Navigator.of(context,rootNavigator: true).pop();


        Fluttertoast.showToast(
            msg: "Password updated.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );

        SharedPreferences storage = await SharedPreferences.getInstance();
        storage.setString("userDetails", response.body);
      }
    }catch(e){
      Navigator.of(context,rootNavigator: true).pop();
      Fluttertoast.showToast(
          msg: "Connection failed.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        title: "Change Password",
        home:Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: false,
            title: Text("Change Password",style: TextStyle(color: Colors.black,fontFamily: "Lato_Bold"),),
            brightness: Brightness.light,
            leading: IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.black),onPressed: (){
              Navigator.pop(context);
            },),
            actions: [
              IconButton(
                onPressed: (){
                  processForm();
                },
                icon: Icon(Icons.check,color: appConfiguration.appColor),
              )
            ],
          ),
          body: ChangePasswordContent(),
        )
    );
  }

  Widget ChangePasswordContent(){
    return Container(
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                validator: (value){
                  if(value.isEmpty){
                    return "Please enter your old password";
                  }
                  var oldPass = md5.convert(utf8.encode(value)).toString();
                  if(oldPass != widget.userDetails['password']){
                    return "Your old password is incorrect";
                  }

                  return null;
                },
                controller: oldPassword,
                decoration: InputDecoration(
                    labelText: "Old Password"
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 0, right: 20),
              child: TextFormField(
                validator: (value){
                  
                  if(!isLength(value, 5)){
                    return 'Your password is too short';
                  }
                  return null;
                },
                controller: newPassword,
                decoration: InputDecoration(
                    labelText: "New Password"
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}

