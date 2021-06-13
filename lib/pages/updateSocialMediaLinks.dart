import 'dart:convert';
// import 'dart:io';

// import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';
// import 'package:string_validator/string_validator.dart';
import '../config.dart';

void main(){
  runApp(UpdateSocialMediaLinks());
}

class UpdateSocialMediaLinks extends StatefulWidget {
  final userDetails;

  UpdateSocialMediaLinks({Key key, @required this.userDetails}) : super(key: key);
  @override
  _UpdateSocialMediaLinksState createState() => _UpdateSocialMediaLinksState();
}

class _UpdateSocialMediaLinksState extends State<UpdateSocialMediaLinks> {
  Config appConfiguration = new Config();
  final _formKey = GlobalKey<FormState>();
  TextEditingController facebook = TextEditingController();
  TextEditingController twitter = TextEditingController();
  TextEditingController instagram = TextEditingController();
  var loading = true;
  var failed = false;
  var socialMediaLinks;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSocialMediaLinks();
  }


  void getSocialMediaLinks()async{
    try{


      var url = appConfiguration.apiBaseUrl + 'getFashionDesignerSocialLinks.php';
      var data = {
        'user_id': widget.userDetails['user_id'].toString()
      };

      var response = await http.post(url, body: data);
      var socialMediaLinks = jsonDecode(response.body);

      for(var i=0; i<socialMediaLinks.length; i++){


        if(socialMediaLinks[i]['site_name'] == 'Twitter'){
          twitter.text = socialMediaLinks[i]['link'];
        }else if (socialMediaLinks[i]['site_name'] == 'Instagram'){
          instagram.text = socialMediaLinks[i]['link'];
        }else{
          facebook.text = socialMediaLinks[i]['link'];
        }
      }

      if(!mounted) return;
      setState(() {
        loading = false;
      });
    }catch(e){
      setState(() {
        failed = true;
      });
    }
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
                    new Text("updating social media links..."),
                  ],
                ),
              ),
            );
          },
        );


        var links = [
          {
            'siteName': 'Facebook',
            'link': facebook.text
          },{
            'siteName': 'Twitter',
            'link': twitter.text
          },{
            'siteName': 'Instagram',
            'link': instagram.text
          }
        ];
        var data = {
          'user_id': widget.userDetails['user_id'].toString(),
          'socialMediaLinks': jsonEncode(links)
        };


        var url = appConfiguration.apiBaseUrl + 'updateSocialMediaLinks.php';
        var response = await http.post(url, body:data);
        print(response.body);
        Navigator.of(context,rootNavigator: true).pop();



        Fluttertoast.showToast(
            msg: "Profile updated.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }catch(e){
      print(e);
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
        title: "Update Social Media Links",
        home:Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: false,
            title: Text("Update Social Media Links",style: TextStyle(color: Colors.black,fontFamily: "Lato_Bold"),),
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
          body: UpdateSocialMediaLinksContent(),
        )
    );
  }

  Widget UpdateSocialMediaLinksContent(){


    if(failed){
      return Center(
        child: Column(
          children: [
            Icon(Icons.wifi, size: 200, color: Colors.black26),
            Text("Oops! connection failed",
                style: TextStyle(
                    fontFamily: "Lato_Regular",
                    fontSize: 20,
                    color: Colors.black45)),
            RaisedButton(
                onPressed: () {
                  if (!mounted) return;
                  setState(() {
                    loading = true;
                    failed = false;
                  });
                  getSocialMediaLinks();
                },
                child:
                Text("TRY AGAIN", style: TextStyle(fontFamily: "Lato_Bolf")))
          ],
        ),
      );
    }
    if(loading){
      return Container(
        color: Colors.white,
        child: Center(child: SpinKitWave(
          color: Colors.blue,
          size: 20.0,
        )),
      );
    }

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
                  if(value.isNotEmpty && !isURL(value)){
                      return 'Please enter a valid link';
                  }
                  return null;
                },
                controller: facebook,
                decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 0,right:0, top: 15),
                      child: FaIcon(FontAwesomeIcons.facebook,color: Colors.black45,size: 20,),
                    ),
                    labelText: "Facebook"
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 0, right: 20),
              child: TextFormField(
                validator: (value){
                  if(value.isNotEmpty && !isURL(value)){
                    return 'Please enter a valid link';
                  }
                  return null;
                },
                controller: twitter,
                decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 0,right:0, top: 15),
                      child: FaIcon(FontAwesomeIcons.twitter,color: Colors.black45,size: 20,),
                    ),
                    labelText: "Twitter"
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20, right: 20),
              child: TextFormField(
                validator: (value){
                  if(value.isNotEmpty && !isURL(value)){
                    return 'Please enter a valid link';
                  }
                  return null;
                },
                controller: instagram,
                decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 0,right:0, top: 15),
                      child: FaIcon(FontAwesomeIcons.instagram,color: Colors.black45,size: 20,),
                    ),
                    labelText: "Instagram"
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}

