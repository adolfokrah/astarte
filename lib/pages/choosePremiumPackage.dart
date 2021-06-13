import 'dart:convert';

import 'package:astarte/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:url_launcher/url_launcher.dart';

void main(){
  runApp(ChoosePremiumServices());
}

class ChoosePremiumServices extends StatefulWidget {
  final userData;

  ChoosePremiumServices({Key key, @required this.userData}) : super(key: key);

  @override
  _ChoosePremiumServicesState createState() => _ChoosePremiumServicesState();
}

class _ChoosePremiumServicesState extends State<ChoosePremiumServices> {
  Config appConfiguration = new Config();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        title: "Subscribe",
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              brightness: Brightness.light,
              centerTitle: false,
              title: Text("Become a premium member", style: TextStyle(color: Colors.black, fontFamily: "Lato_Black"),),
              leading: IconButton(icon: Icon(CupertinoIcons.back, color: Colors.black),onPressed: (){
                Navigator.pop(context);
              },),
            ),
            body:ChoosePremiumServicesContent()
        ));
  }

  Widget ChoosePremiumServicesContent(){
    return ListView(
      padding: EdgeInsets.only(bottom:20),
      children: [
        Container(
          padding: EdgeInsets.only(top:0, bottom:0, left: 60, right: 60),
          child: Image.asset("assets/images/hero.png",scale: 4,),
        ),
         Padding(
           padding: const EdgeInsets.all(30.0),
           child: Text("Continue with your journey of reaching millions of customers", style: TextStyle(fontFamily: "Lato_Black",fontSize: 20),textAlign: TextAlign.center,),
         ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 5),
          child: Text("Excel by exhibiting your skills to millions of people who need you.", style: TextStyle(fontFamily: "Lato_Regular",fontSize: 16),textAlign: TextAlign.center,),
        ),
        Container(
          margin: EdgeInsets.only(top: 20),
          height: 250,
          child: new Swiper(
            pagination: new SwiperPagination(
              margin: EdgeInsets.only(top: 30),
              alignment: Alignment.bottomCenter,
              builder: new DotSwiperPaginationBuilder(
                  color: Colors.grey, activeColor: Color(0xff38547C)),
            ),
            loop: false,
            itemBuilder: (BuildContext context, int i) {
              return Container(
                 padding: EdgeInsets.all(20),
                 child: Container(
                   padding: EdgeInsets.all(20),
                   child: Column(
                     children: [
                        Padding(
                          padding: const EdgeInsets.only(top:20.0),
                          child: Text(widget.userData['packages'][i]['package_name'], style: TextStyle(fontFamily: "Lato_Black",fontSize: 30),),
                        ),
                        Text('¢'+double.parse(widget.userData['packages'][i]['price']).toStringAsFixed(2),style: TextStyle(fontFamily: "Lato_Regular",fontSize: 16)),
                       Padding(
                         padding: const EdgeInsets.only(top: 21.0),
                         child: FlatButton(
                             minWidth: 250,
                             height: 50,
                             onPressed: ()async{
                               var id =  base64.encode(utf8.encode(widget.userData['user_id']));
                               var package_id =  base64.encode(utf8.encode(widget.userData['packages'][i]['id']));
                               var url = appConfiguration.apiBaseUrl+'subscribe.php?user_id='+id+'&package_id='+package_id;

                              try{
                                FlutterWebBrowser.openWebPage(
                                  url: url,
                                  customTabsOptions: CustomTabsOptions(
                                    colorScheme: CustomTabsColorScheme.light,
                                    toolbarColor: Colors.white,
                                    secondaryToolbarColor: Colors.white,
                                    navigationBarColor: Colors.white,
                                    addDefaultShareMenuItem: true,
                                    instantAppsEnabled: true,
                                    showTitle: true,
                                    urlBarHidingEnabled: true,
                                  ),
                                  safariVCOptions: SafariViewControllerOptions(
                                    barCollapsingEnabled: true,
                                    preferredBarTintColor: Colors.white,
                                    preferredControlTintColor: Colors.black,
                                    dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                                    modalPresentationCapturesStatusBarAppearance: true,
                                  ),
                                );
                              }catch(e){
                                if (await canLaunch(url)) {
                                 await launch(url);
                                 } else {
                                 throw 'Could not launch $url';
                                 }
                              }
                         },
                             child: Text("SELECT PACKAGE",style: TextStyle(fontFamily: "Lato_Bold",color:Colors.white),),
                             color: Colors.black,
                             shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(100.0),
                                 side: BorderSide(color: Colors.black)
                             )
                         ),
                       )
                     ],
                   ),
                   decoration: BoxDecoration(
                      color: Color(0xfff5f5f5),
                     borderRadius: BorderRadius.circular(20.0),
                       border: Border.all(color: Colors.blue,width: 5)

                   ),
                 ),
              );
            },
            itemCount: widget.userData['packages'].length,
            control: null,
          ),
        )
      ],
    );
  }
}
