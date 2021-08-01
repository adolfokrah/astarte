import 'dart:convert';

import 'package:astarte/config.dart';
import 'package:astarte/pages/accountPage.dart';
import 'package:astarte/pages/createPost.dart';
import 'package:astarte/pages/feed.dart';
import 'package:astarte/pages/login.dart';
import 'package:astarte/pages/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'blockedPage.dart';
import 'delivery.dart';
import 'notifications.dart';

// void main() {
//   runApp(LandingPage());
// }

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  var currentTab = 0;
  Config appConfiguration = new Config();
  var tabs = [Feed(),SearchPage(),Notifications(),Delivery(),AccountPage()];

  var userId  = "0";
  var userDetailsState;

  List<Asset> images = List<Asset>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();

  }

  Future fetchUserDetails()async{
    try{
     if(userId == "0") return;
      var url = appConfiguration.apiBaseUrl + 'getUserDetails.php';
      var response = await http.post(url, body: {
        'id': userId.toString(),
      });


      if(jsonDecode(response.body)['status'] == 'blocked'){
        SharedPreferences storage = await SharedPreferences.getInstance();
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
  void openLoginPage(){
    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
  }


  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 4,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#1f75de",
          actionBarTitle: "Add Photos",
          actionBarTitleColor: '#ffffff',
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#ffffff",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
      print(e);
    }


    if(resultList.length > 0){
     var data = await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: CreatePost(images: resultList)));
     if(data == 'done'){

     }
    }

  }

  getUserDetails() async {
    try {

      SharedPreferences storage = await SharedPreferences.getInstance();
      String userDetails = storage.getString('userDetails');

      String user_id = "0";
      if (userDetails != null) {
        fetchUserDetails();
        var userDetailsArray = jsonDecode(userDetails);
        user_id = userDetailsArray['user_id'].toString();
        if (!mounted) return;
        setState(() {
          userId = user_id.toString();
          userDetailsState = userDetailsArray;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: appConfiguration.appColor),
      title: "Astarte",
      home: WillPopScope(
        onWillPop: ()async{
          if(currentTab > 0){
            setState(() {
              currentTab = 0;
            });
            return false;
          }else{
            return true;
          }

        },
        child: Scaffold(
            body: IndexedStack(
              index: currentTab,
              children:tabs,
            ),
            bottomNavigationBar: BottomAppBar(
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(width: 0.5, color: Colors.black12))),
                child: userDetailsState != null && userDetailsState['user_type'] == 'customer' ? customer() : designerMenu(),
              ),
            )),
      ),
    );
  }

  Widget designerMenu(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
            icon: Icon(currentTab == 0 ? CupertinoIcons.house_fill : CupertinoIcons.house), onPressed: () {
          if(!mounted) return;
          setState(() {
            currentTab = 0;
          });
        }),
        IconButton(
          icon: Icon(currentTab == 1 ? CupertinoIcons.search_circle_fill : CupertinoIcons.search),
          onPressed: () {
            if(!mounted) return;
            setState(() {
              currentTab = 1;
            });
          },
        ),
        IconButton(icon: Icon(CupertinoIcons.add_circled), onPressed: () {
          if(userId == "0"){
            openLoginPage();
            return;
          }
          loadAssets();
        }),
        IconButton(icon: Icon(currentTab == 2 ? CupertinoIcons.bell_fill : CupertinoIcons.bell), onPressed: () {
          if(userId == "0"){
            openLoginPage();
            return;
          }

          if(!mounted) return;
          setState(() {
            currentTab = 2;
          });
        }),
        IconButton(icon: Icon(currentTab == 4 ? CupertinoIcons.person_fill : CupertinoIcons.person), onPressed: () {

          if(userId == "0"){
            openLoginPage();
            return;
          }
          if(!mounted) return;
          setState(() {
            currentTab = 4;
          });
        }),
      ],
    );
  }

  Widget customer(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
            icon: Icon(currentTab == 0 ? CupertinoIcons.house_fill : CupertinoIcons.house), onPressed: () {
          if(!mounted) return;
          setState(() {
            currentTab = 0;
          });
        }),
        IconButton(
          icon: Icon(currentTab == 1 ? CupertinoIcons.search_circle_fill : CupertinoIcons.search),
          onPressed: () {
            if(!mounted) return;
            setState(() {
              currentTab = 1;
            });
          },
        ),
        IconButton(icon: Icon(currentTab == 2 ? CupertinoIcons.bell_fill : CupertinoIcons.bell), onPressed: () {
          if(userId == "0"){
            openLoginPage();
            return;
          }

          if(!mounted) return;
          setState(() {
            currentTab = 2;
          });
        }),
        IconButton(icon: Icon(currentTab == 3 ? CupertinoIcons.cube_box_fill : CupertinoIcons.cube_box,),
            onPressed: () {

          if(userId == "0"){
            openLoginPage();
            return;
          }
          if(!mounted) return;
          setState(() {
            currentTab = 3;
          });
        }),
        IconButton(icon: Icon(currentTab == 4 ? CupertinoIcons.person_fill : CupertinoIcons.person,),
            onPressed: () {

              if(userId == "0"){
                openLoginPage();
                return;
              }
              if(!mounted) return;
              setState(() {
                currentTab = 4;
              });
        }),
      ],
    );
  }
}
