import 'dart:async';
import 'dart:math';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:snack/snack.dart';
import 'package:http/http.dart' as http;


import '../../config.dart';

void main(){
  runApp(PhoneVerification());
}

class PhoneVerification extends StatefulWidget {
  final userInfo;

  PhoneVerification({Key key, @required this.userInfo}) : super(key: key);
  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  Config appConfiguration = new Config();
  String _verificationId;

  var onTapRecognizer;

  TextEditingController textEditingController = TextEditingController();
  // ..text = "123456";

  StreamController<ErrorAnimationType> errorController;

  bool hasError = false;
  String currentText = "";
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  var verficationCode = '';
  var loading = false;

  @override
  void initState(){
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        sendOTP();

      };
    errorController = StreamController<ErrorAnimationType>();

    super.initState();

    // verifyPhoneNumber();
    sendOTP();
  }


  void sendOTP() async {

    try{


      Fluttertoast.showToast(
          msg: "Verification code sent",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      var rng = new Random();
      var code = rng.nextInt(1000) + 1000;
      if(!mounted) return;
      setState(() {
        verficationCode = code.toString();
      });

      var message = 'Your verification code: '+code.toString();
      var url = "https://apps.mnotify.net/smsapi?key="+appConfiguration.smsApiKey+"&to="+widget.userInfo['mobile_number']+"&msg="+message+"&sender_id="+appConfiguration.senderId;

      print(code);
      var response = await http.get(url);


    }catch(e){
      print(e);
      Fluttertoast.showToast(
          msg: "Failed, couldn't send verification code",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }
  void verifyPhoneNumber() async {


    //
    // PhoneVerificationCompleted verificationCompleted =
    //     (PhoneAuthCredential phoneAuthCredential) async {
    //   await _auth.signInWithCredential(phoneAuthCredential);
    //   final bar = SnackBar(
    //       content: Text("Phone number automatically verified and user signed in: ${_auth.currentUser.uid}",
    //           style: TextStyle(fontFamily: "Lato_Bold")));
    //   bar.show(context);
    // };
    //
    // PhoneVerificationFailed verificationFailed =
    //     (FirebaseAuthException authException) {
    //   final bar = SnackBar(
    //       content: Text('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}',
    //           style: TextStyle(fontFamily: "Lato_Bold")));
    //   bar.show(context);
    // };
    //
    // //Callback for when the code is sent
    // PhoneCodeSent codeSent =
    //     (String verificationId, [int forceResendingToken]) async {
    //   final bar = SnackBar(
    //       content: Text('Please check your phone for the verification code.',
    //           style: TextStyle(fontFamily: "Lato_Bold")));
    //   bar.show(context);
    //   _verificationId = verificationId;
    //
    //     };
    //
    // PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
    //     (String verificationId) {
    //       final bar = SnackBar(
    //           content: Text("verification code: " + verificationId,
    //               style: TextStyle(fontFamily: "Lato_Bold")));
    //       bar.show(context);
    //   _verificationId = verificationId;
    //
    // };
    //
    // await _auth.verifyPhoneNumber(
    //     phoneNumber: '+233245301631',
    //     timeout: const Duration(seconds: 5),
    //     verificationCompleted: verificationCompleted,
    //     verificationFailed: verificationFailed,
    //     codeSent: codeSent,
    //     codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

    // await FirebaseAuth.instance.verifyPhoneNumber(
    //   phoneNumber: '+233245301631',
    //
    //   verificationCompleted: (PhoneAuthCredential credential) {
    //     print('verificationCompleted');
    //
    //   },
    //   verificationFailed: (FirebaseAuthException e) {
    //     print('verificationFailed');
    //     if (e.code == 'invalid-phone-number') {
    //       print('The provided phone number is not valid.');
    //     }
    //     else {
    //       print('Some error occoured: $e');
    //     }
    //   },
    //   codeSent: (String verificationId, int resendToken) async {
    //     print('codeSent');
    //
    //     // Update the UI - wait for the user to enter the SMS code
    //     String smsCode = '123456';
    //
    //     // Create a PhoneAuthCredential with the code
    //     PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    //
    //   },
    //   timeout: const Duration(seconds: 60),
    //   codeAutoRetrievalTimeout: (String verificationId) {
    //     print("Timeout: $verificationId");
    //   },
    // );

  }

  @override
  void dispose() {
    errorController.close();

    super.dispose();
  }


  void validatePin(){
    formKey.currentState.validate();
    // conditions for validating

    if (currentText.length != 4 || currentText != verficationCode) {
      errorController.add(ErrorAnimationType
          .shake); // Triggering error shake animation
      setState(() {
        hasError = true;
      });
    } else {
      setState(() {
        hasError = false;
      });

      //register user
      registerUser();
    }
  }

  Future<void> registerUser()async{
      try{

        if(!mounted) return;
        setState(() {
          loading = true;
        });

        var url = appConfiguration.apiBaseUrl + 'registerUser.php';
        // var response = await http.post(url, body: widget.userInfo);

        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.files.add(await http.MultipartFile.fromPath('photo',widget.userInfo['photoPath']));
        request.fields.addAll(widget.userInfo);
        var res = await request.send();
        var response = await res.stream.bytesToString();


        if(!mounted) return;
        setState(() {
          loading = false;
        });

       if(response == '0'){
         Fluttertoast.showToast(
             msg: "Sorry! it seems you already have an account with us.",
             toastLength: Toast.LENGTH_SHORT,
             gravity: ToastGravity.BOTTOM,
             timeInSecForIosWeb: 1,
             backgroundColor: Colors.black,
             textColor: Colors.white,
             fontSize: 16.0
         );
         return;
       }

        SharedPreferences storage = await SharedPreferences.getInstance();
        storage.setString("userDetails", response);

        // print(response.body);
        Phoenix.rebirth(context);

      }catch(e){
        print(e);
        Fluttertoast.showToast(
            msg: "Connection failed.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
        if(!mounted) return;
        setState(() {
          loading = false;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: appConfiguration.appColor),
      title: "Customer SignUp",
      home: LoadingOverlay(
        isLoading:  loading,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              brightness: Brightness.light,
              leading: IconButton(icon: Icon(CupertinoIcons.back, color: Colors.black),onPressed: (){
                Navigator.pop(context);
              },),
            ),
            body: pinCodeContent()
        ),
      ),
    );
  }

  Widget pinCodeContent(){
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Phone Number Verification',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,fontFamily: "Lato_Bold"),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: RichText(
                  text: TextSpan(
                      text: "Enter the code sent to ",
                      children: [
                        TextSpan(
                            text: widget.userInfo['mobile_number'],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,fontFamily: "Lato_Regular")),
                      ],
                      style: TextStyle(color: Colors.black54, fontSize: 15)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 30),
                    child: PinCodeTextField(
                      appContext: context,

                      pastedTextStyle: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 4,
                      obscureText: false,
                      obscuringCharacter: '*',
                      animationType: AnimationType.fade,
                      validator: (v) {
                        if (v.length < 3) {
                          return "I'm from validator";
                        } else {
                          return null;
                        }
                      },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 60,
                        fieldWidth: 50,
                        activeColor: Colors.black12,
                        selectedFillColor: Colors.black12,
                        inactiveFillColor: Colors.black12,
                        activeFillColor:
                        hasError ? Colors.black12 : Colors.black12,
                      ),
                      cursorColor: Colors.black,
                      animationDuration: Duration(milliseconds: 300),
                      textStyle: TextStyle(fontSize: 20, height: 1.6),
                      backgroundColor: Colors.white,
                      enableActiveFill: true,
                      errorAnimationController: errorController,
                      controller: textEditingController,
                      keyboardType: TextInputType.number,
                      onCompleted: (v) {
                        validatePin();
                      },
                      // onTap: () {
                      //   print("Pressed");
                      // },
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          currentText = value;
                        });
                      },
                      beforeTextPaste: (text) {
                        print("Allowing to paste $text");
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return true;
                      },
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  hasError ? "You entered an incorrect pin" : "",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,fontFamily: "Lato_Regular"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "Didn't receive the code? ",
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontFamily: "Lato_Regular"),
                    children: [
                      TextSpan(
                          text: " RESEND",
                          recognizer: onTapRecognizer,
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,fontFamily: "Lato_Black"))
                    ]),
              ),
              SizedBox(
                height: 14,
              ),
              Container(
                margin:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                child: ButtonTheme(
                  height: 50,
                  child: FlatButton(
                    onPressed: () {
                      validatePin();
                    },
                    child: Center(
                        child: Text(
                          "VERIFY".toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5)),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
