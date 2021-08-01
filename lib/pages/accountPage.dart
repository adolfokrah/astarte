import 'dart:convert';

import 'package:astarte/pages/changePassword.dart';
import 'package:astarte/pages/delivery.dart';
import 'package:astarte/pages/editProfile.dart';
import 'package:astarte/pages/myPosts.dart';
import 'package:astarte/pages/myReviews.dart';
import 'package:astarte/pages/premiumService.dart';
import 'package:astarte/pages/updateShopDetails.dart';
import 'package:astarte/pages/updateSocialMediaLinks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import 'blockedPage.dart';

void main(){
  runApp(AccountPage());
}

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  var userId = '0';
  var userDetailsState = {};
  Config appConfiguration = Config();


  var menu = [
    {
      'menu_title':"My Post",
      'icon':CupertinoIcons.doc_append,
      'link':'/post',
      'user_type':'admin'
    },
    {
      'menu_title':"Delivery",
      'icon':CupertinoIcons.cube_box,
      'link':'/delivery',
      'user_type':'admin'
    },
    {
      'menu_title': 'Premium Services',
      'icon': CupertinoIcons.star_circle,
      'link':'/premium',
      'user_type':'admin'
    },
    {
      'menu_title': 'Social networks',
      'icon':CupertinoIcons.staroflife,
      'link':'/social',
      'user_type':'admin'
    },
    {
      'menu_title': 'Reviews',
      'icon':CupertinoIcons.chat_bubble,
      'link':'/review',
      'user_type':'admin'
    },
    {
      'menu_title': 'My Shop',
      'icon':CupertinoIcons.shopping_cart,
      'link':'/shop',
      'user_type':'admin'
    },
    {
      'menu_title': 'Change Password',
      'icon':CupertinoIcons.lock,
      'link':'/pass',
      'user_type':'all'
    },
    {
      'menu_title': 'Rate us',
      'icon':CupertinoIcons.star,
      'link':'/',
      'user_type':'all'
    },
    {
      'menu_title': 'About us',
      'icon':CupertinoIcons.info,
      'link':'https://astarte.biztrustgh.com/docs/about-us.php',
      'user_type':'all'
    },
    {
      'menu_title': 'Privacy Policy',
      'icon':CupertinoIcons.doc,
      'link':'https://astarte.biztrustgh.com/docs/privacy-policy.php',
      'user_type':'all'
    },
    {
      'menu_title': 'Terms & Conditions',
      'icon':CupertinoIcons.doc_chart,
      'link':'https://astarte.biztrustgh.com/docs/terms-and-conditions.php',
      'user_type':'all'
    },
    {
      'menu_title': 'Log out',
      'icon':CupertinoIcons.power,
      'link':'/logout',
      'user_type':'all'
    }
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    try {

      SharedPreferences storage = await SharedPreferences.getInstance();
      String userDetails = storage.getString('userDetails');
      // storage.clear();
      String user_id = "0";
      if (userDetails != null) {
        var userDetailsArray = jsonDecode(userDetails);
        user_id = userDetailsArray['user_id'].toString();
        if (!mounted) return;
        setState(() {
          userId = user_id.toString();
          userDetailsState = userDetailsArray;
        });
        // print(userDetailsArray);
      }
    } catch (e) {
      print(e);
    }
  }

  Future fetchUserDetails()async{
    try{
      var url = appConfiguration.apiBaseUrl + 'getUserDetails.php';
      var response = await http.post(url, body: {
        'id': userId.toString(),
      });

      SharedPreferences storage = await SharedPreferences.getInstance();
      storage.setString("userDetails", response.body);
      if(!mounted) return;
      setState(() {
        userDetailsState  = jsonDecode(response.body);
      });

      if(jsonDecode(response.body)['status'] == 'blocked'){
        storage.clear();
        Navigator.pushReplacement(context, PageTransition(
            type: PageTransitionType.rightToLeft,
            child: BlockedPage()));
        return;
      }
    }catch(e){
      print(e);
    }
  }


  Future accountStatus()async{
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Account Subscription Status'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your subscription is active till '+userDetailsState['premium_expiration']),
              ],
            ),
          ),
        );
      },
    );
  }

  Future logout()async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async{

                SharedPreferences storage = await SharedPreferences.getInstance();
               storage.clear();
               Phoenix.rebirth(context);
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }


  Future<void> openLink(url)async{
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
  }
  @override
  Widget build(BuildContext context) {
    if(userId == '0'){
      return Container();
    }
    return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
        AppBar(
        toolbarHeight: 50,
        title: InkWell(
          onTap: ()async{
            var data = await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: EditProfile(userDetails: userDetailsState,)));
            getUserDetails();
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: CircleAvatar(
                    radius: 15,
                    backgroundImage: CachedNetworkImageProvider(
                       appConfiguration.apiBaseUrl+''+userDetailsState['photo'])),
              ),
              Text(userDetailsState['user_type'] == 'customer' ? userDetailsState['full_name'] :userDetailsState['brand_name'],
                  style: TextStyle(fontFamily: "Lato_Black", color: Colors.black)),
              Icon(CupertinoIcons.chevron_down, color: Colors.black,)
            ],
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        brightness: Brightness.light,
      ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 0),
            itemCount: menu.length,
            itemBuilder: (context, index){
              if(userDetailsState['user_type'] == 'customer' && menu[index]['user_type'] == 'all' || userDetailsState['user_type'] != 'customer') {
                return InkWell(
                  onTap: ()async {

                    await getUserDetails();

                    if(menu[index]['menu_title'] == 'Privacy Policy' || menu[index]['menu_title'] == 'Terms & Conditions' || menu[index]['menu_title'] == 'About us'){
                        openLink(menu[index]['link']);
                    }

                    if (menu[index]['link'] == '/logout') {
                      logout();
                    }

                    if (menu[index]['link'] == '/pass') {
                      Navigator.push(context, PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ChangePassword(
                            userDetails: userDetailsState,)));
                    }

                    if (menu[index]['link'] == '/shop') {
                      Navigator.push(context, PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: UpdateShopDetails(
                            userDetails: userDetailsState,)));
                    }

                    if (menu[index]['link'] == '/social') {
                      Navigator.push(context, PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: UpdateSocialMediaLinks(
                            userDetails: userDetailsState,)));
                    }

                    if (menu[index]['link'] == '/delivery') {
                      Navigator.push(context, PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: Delivery()));
                    }

                    if (menu[index]['link'] == '/post') {
                      Navigator.push(context, PageTransition(
                          type: PageTransitionType.rightToLeft, child: MyPosts(
                        userId: userDetailsState['user_id'],)));
                    }

                    if (menu[index]['link'] == '/review') {
                      Navigator.push(context, PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: MyReviews(
                            userId: userDetailsState['user_id'],)));
                    }

                    if (menu[index]['link'] == '/premium') {
                       if(userDetailsState['premium'] == 'true'){
                            accountStatus();
                       }else{
                         var data = await Navigator.push(context, PageTransition(
                             type: PageTransitionType.rightToLeft,
                             child: PremiumServices(userData: userDetailsState,)));

                         await fetchUserDetails();
                       }
                    }
                  },
                  child: ListTile(
                    leading: Icon(menu[index]['icon'], color: Colors.black,),
                    title: Text(menu[index]['menu_title'],
                      style: TextStyle(fontFamily: "lato_Regular"),),
                  ),
                );
              }else{
                return Container();
              }
            },
          ),
        )
        ]
    );
  }
}
