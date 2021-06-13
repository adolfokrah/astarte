import 'package:astarte/pages/signupPages/uploadPhoto.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:string_validator/string_validator.dart';

import '../../config.dart';
import '../login.dart';

void main(){
  runApp(CustomerSignUp());
}

class CustomerSignUp extends StatefulWidget {
  @override
  _CustomerSignUpState createState() => _CustomerSignUpState();
}

class _CustomerSignUpState extends State<CustomerSignUp> {
  Config appConfiguration = new Config();
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController password = TextEditingController();

  var countryCodeSelected = '+233';
  var visible = true;


  void getCountryCode(CountryCode countryCode){
    setState(() {
      countryCodeSelected = countryCode.toString();
    });
  }

  void processForm(){
    if(_formKey.currentState.validate()) {
      var customerData = {
        'full_name':fullName.text,
        'email': email.text,
        'mobile_number': countryCodeSelected+mobileNumber.text,
        'password': password.text,
        'userType': 'customer',
        'lat':"0",
        'lng':"0",
        'brand_name':'',
        'premium_expiration':'000-00-00',
        'about':'',
        'address':'',
        'status':'active'
      };
      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UploadPhoto(userInfo:customerData)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: appConfiguration.appColor),
      title: "Customer SignUp",
      home: Scaffold(
          appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          brightness: Brightness.light,
          leading: IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.black),onPressed: (){
          Navigator.pop(context);
          },),
          ),
        body: signUpContainer(),
      ),
    );
  }

  Widget signUpContainer(){
    return Column(
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
                        Text("Sign Up",style: TextStyle(fontFamily: "Lato_Black",fontSize: 30),),
                        Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("Register as a customer and reach millions of skillful fashion designers",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 15),textAlign: TextAlign.center,))
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
                            controller: fullName,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                fillColor: Colors.black12,
                                filled: true,
                                hintText: "Full Name",
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
                                return 'Please enter your full name';
                              }

                              // if(!isAlpha(value)){
                              //   return "Please do not include special characters";
                              // }

                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20,bottom:20),
                          child: TextFormField(
                            controller: email,
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
                                return 'Please enter your email';
                              }

                              if(!isEmail(value)){
                                return "Please enter a valid email address";
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20,bottom:20),
                          child: TextFormField(
                            controller: mobileNumber,
                            decoration: InputDecoration(
                                 prefixIcon: Padding(
                                   padding: EdgeInsets.only(left: 5,right: 5),
                                   child: CountryCodePicker(
                                     onChanged: getCountryCode,
                                     // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                     initialSelection: 'GH',
                                     // optional. Shows only country name and flag
                                     showCountryOnly: false,
                                     // optional. Shows only country name and flag when popup is closed.
                                     showOnlyCountryWhenClosed: false,
                                     // optional. aligns the flag and the Text left
                                     alignLeft: false,
                                   ),
                                 ),
                                contentPadding: EdgeInsets.all(15),
                                fillColor: Colors.black12,
                                filled: true,
                                hintText: "Mobile Number",
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
                                return 'Please enter your phone number';
                              }

                              if(!isNumeric(value)){
                                return "Please enter a valid phone number";
                              }

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

                              if(!isLength(value, 5)){
                                return 'Your password is too short';
                              }


                              return null;
                            },
                          ),
                        ),
                        FlatButton(onPressed: (){
                          processForm();
                        },
                            child: Text("Continue",style: TextStyle(color: Colors.white,fontFamily: "Lato_Bold"),),color: Colors.blue,minWidth: double.infinity,height: 50,shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.blue)
                            )),

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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );



            },
            child: Center(
              child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text:"Already have an account?",
                        style: TextStyle(
                            fontFamily: "Lato_Bold",
                            color: Colors.black87,
                            fontSize: 14)),
                    TextSpan(
                        text: "  Login",
                        style: TextStyle(
                            fontFamily: "Lato_Black",
                            color: Color(0xff0468c5),
                            fontSize: 14))
                  ])),
            ),
          ),
        )
      ],
    );
  }
}
