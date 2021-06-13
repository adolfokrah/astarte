import 'dart:convert';

import 'package:astarte/config.dart';
import 'package:astarte/pages/choosePremiumPackage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;

void main(){
  runApp(PremiumServices());
}

class PremiumServices extends StatefulWidget {
  final userData;

  PremiumServices({Key key, @required this.userData}) : super(key: key);

  @override
  _PremiumServicesState createState() => _PremiumServicesState();
}

class _PremiumServicesState extends State<PremiumServices> {
  Config appConfiguration = new Config();
  ScrollController _scrollController = ScrollController();
  var loading = false;
  var failed = false;
  var packages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPackages();
  }

  Future getPackages()async{
    try{
      if(!mounted) return;
      setState(() {
        loading = true;
      });

      var url = appConfiguration.apiBaseUrl + 'getPackages.php';

      var response = await http.get(url);

      if(!mounted) return;
      setState(() {
        loading = false;
        packages = jsonDecode(response.body);
      });

    }catch(e){
      print(e);
      if(!mounted) return;
      setState(() {
        failed = true;
      });
    }
  }

  void _subscribe(){
    var data = widget.userData;
    data['packages'] = packages;
    Navigator.push(context, PageTransition(
        type: PageTransitionType.rightToLeft,
        child: ChoosePremiumServices(
          userData: data,)));
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        title: "Premium Services",
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              brightness: Brightness.light,
              centerTitle: false,
              title: Text("Premium Services", style: TextStyle(color: Colors.black, fontFamily: "Lato_Black"),),
              leading: IconButton(icon: Icon(CupertinoIcons.back, color: Colors.black),onPressed: (){
                Navigator.pop(context);
              },),
            ),
            body:premiumServicesContent()
        ));
  }

  Widget premiumServicesContent(){

    if (failed){
      return Center(
        child: Column(
          children: [
            Icon(Icons.wifi, size: 200, color: Colors.black26),
            Text("Oops! couldn't fetch feed",
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
                  //getUserDetails();
                },
                child:
                Text("RELOAD", style: TextStyle(fontFamily: "Lato_Bold")))
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

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          Container(
            color: Color(0xff1f75de),
            padding: EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text("Go Premium, reach 10x more customers than usual", style: TextStyle(color: Colors.white, fontSize: 30,fontFamily: "Lato_Black"),),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text("Just ¢${packages[0]['price']}/month after. Cancel anytime.", style: TextStyle(color: Colors.white, fontSize: 17,fontFamily: "Lato_Black"),),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      FlatButton(onPressed: (){
                        _scrollController.animateTo(300, duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
                      },
                          child: Text("LEARN MORE",style: TextStyle(fontFamily: "Lato_Bold",color:Colors.white),),
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                              side: BorderSide(color: Colors.black)
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: FlatButton(onPressed: (){
                          _subscribe();
                        },
                            child: Text("SUBSCRIBE",style: TextStyle(fontFamily: "Lato_Bold",color:Colors.white),),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                side: BorderSide(color: Colors.white)
                            )
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Text("1.",style: TextStyle(fontFamily: "Lato_Black",color: Colors.white),),
                  ),
                  title: Text("Premium in search results and feeds", style: TextStyle(fontFamily: "Lato_Regular"),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 75.0, top: 10, right: 15),
                  child: Text("Your posts will be seen by almost every customer globally", style: TextStyle(fontFamily: "Lato_Regaulr"),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 75.0, top: 10, right: 15),
                  child: Text("Boosted posts and premium fashion designers get up to 10x times more views in the feeds and search results.", style: TextStyle(fontFamily: "Lato_Regular"),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 75.0, top: 10, right: 15),
                  child: Text("Quickly get your post verified", style: TextStyle(fontFamily: "Lato_Regular"),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 75.0, top: 10, right: 15),
                  child: Text("Premium fashion designers are suggested to customers in the search results.", style: TextStyle(fontFamily: "Lato_Regular"),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 55.0, top: 10, right: 15,bottom: 20),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.verified, color: Colors.blueAccent,size: 12,),
                      ),
                      Flexible(child: Text("Premium fashion designers with verified badges are more visible to customers", style: TextStyle(fontFamily: "Lato_Regular"),))
                    ],
                  ),
                ),
                Container(
                  color: Colors.orange,
                  padding: EdgeInsets.only(top: 40,left: 60,right:60),
                  child: Image.asset("assets/images/premium1.png"),
                )
              ],
            )
          ),
          Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text("2.",style: TextStyle(fontFamily: "Lato_Black",color: Colors.white),),
                    ),
                    title: Text("Premium in our social media sponsored ads", style: TextStyle(fontFamily: "Lato_Regular"),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 75.0, top: 10, right: 15),
                    child: Text("Your posts will automatically be promoted on our social media handles", style: TextStyle(fontFamily: "Lato_Regular"),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 75.0, top: 10, right: 15),
                    child: Text("Reach more customers not only in our app but millions of customers on social media platforms.", style: TextStyle(fontFamily: "Lato_Regular"),),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 40,left: 40,right:40),
                    child: Image.asset("assets/images/premium2.png"),
                  )
                ],
              )
          ),
          Container(
            color: Color(0xff1f75de),
            padding: EdgeInsets.only(top: 70,left: 40,right:40,bottom: 70),
            child: Column(
              children: [
                Text("Premium services are the best way to reach maximum customers",textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontFamily: "Lato_Bold",fontSize: 20),),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(onPressed: (){
                      _subscribe();
                  },
                      color: Colors.green,
                      child: Text("TRY NOW",style: TextStyle(fontFamily: "Lato_Bold",color:Colors.white),),
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.green)
                      )
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
