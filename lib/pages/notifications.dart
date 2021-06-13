import 'dart:convert';

import 'package:astarte/pages/fashionDesignerProfile.dart';
import 'package:astarte/pages/login.dart';
import 'package:astarte/pages/savedPost.dart';
import 'package:astarte/pages/singleFeed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snack/snack.dart';

import '../config.dart';

void main(){
  runApp(Notifications());
}
class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  Config appConfiguration = Config();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  var loading = true;
  var failed = false;
  var start = 0;
  var userId = '7';
  var notifications = [];
  var nstart = 0;

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
      String user_id = "0";
      if (userDetails != null) {
        var userDetailsArray = jsonDecode(userDetails);
        user_id = userDetailsArray['user_id'].toString();
        if (!mounted) return;
        setState(() {
          userId = user_id;
        });
        fetchNotifications('desc');
        return;
      }
      fetchNotifications('desc');
    } catch (e) {
      print(e);
    }
  }

  void toggleNotificationSubscription(postedBy) async{
    try{
      var myFeeds = notifications;

      if(userId =='0'){
        return;
      }


      var url = appConfiguration.apiBaseUrl + 'togglePostNotification.php';
      var response = await http.post(url, body: {
        'subscriber': userId.toString(),
        'posted_by': postedBy
      });


      var message = "";
      for(var i=0; i<myFeeds.length; i++){
        if(myFeeds[i]['sent_by'] == postedBy){
          if(myFeeds[i]['subscribed'] == 'true'){
            myFeeds[i]['subscribed'] = '0';
            message = "Post notification off";
          }else{
            myFeeds[i]['subscribed'] = 'true';
            message = "Post notification on";
          }
          break;
        }
      }

      if(!mounted) return;
      setState(() {
        notifications = myFeeds;
      });

      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      print(response.body);
    }catch(e){
      print(e);
      final bar = SnackBar(
          content: Text('Oops! connection failed',
              style: TextStyle(fontFamily: "Lato_Bold")));
      bar.show(context);
    }
  }

  Future deleteNotifcation(notificationId) async{
    try{

      Fluttertoast.showToast(
          msg: "Removing notification",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      var url = appConfiguration.apiBaseUrl + 'deleteNotification.php';
      var response = await http.post(url, body: {
        'notification_id': notificationId.toString(),
      });

      var notifcations = notifications;
      notifcations.removeWhere((notification) => notification['notification_id'] == notificationId);
      setState(() {
        notifications = notifcations;
        start = notifications.length < 1 ? 0 : start ;
      });




      Fluttertoast.showToast(
          msg: "Notification Removed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

    }catch(e){
      print(e);
      final bar = SnackBar(
          content: Text('Oops! connection failed',
              style: TextStyle(fontFamily: "Lato_Bold")));
      bar.show(context);
    }
  }

  Future fetchNotifications(order)async{
    try{
      var mstart = start;
      if (order == 'asc') {
        mstart = nstart;
      }


      var url = appConfiguration.apiBaseUrl + 'fetchNotificatons.php';
      var response = await http.post(url, body: {
        'userId': userId.toString(),
        'start': mstart.toString(),
        'order': order
      });

      var data = jsonDecode(response.body);


      var notifcations = notifications;
      var newNotifications = [];

      if (order == 'asc') {
        newNotifications = []..addAll(data)..addAll(notifcations);
      } else {
        newNotifications = []..addAll(notifcations)..addAll(data);
      }

      if(!mounted) return;
      setState(() {
        notifications = newNotifications;
        loading = false;
      });

      if (order == 'asc' || start == 0) {

        if (!mounted) return;
        setState(() {
          nstart = int.parse(data[0]['notification_id']);
        });
      }


      if(data.length > 0){
        if(!mounted) return;
        setState(() {
          start = start + 10;
        });
      }

    }catch(e){
      if(!mounted) return;
      setState(() {
        failed = true;
      });
    }
  }

  void _onRefresh() async {
    // monitor network fetch
    // await getNewFeeds();

    await fetchNotifications('asc');
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    // await getNewFeeds();
    await fetchNotifications('desc');
    _refreshController.loadComplete();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
       children: [
         AppBar(
           toolbarHeight: 50,
           title: Text("Notifications",
               style: TextStyle(fontFamily: "Lato_Black", color: Colors.black)),
           centerTitle: false,
           backgroundColor: Colors.white,
           elevation: 0.5,
           brightness: Brightness.light,
         ),
        Expanded(
      child: Container(
          decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 1)),
          color: Colors.white,),
          child: loading ? loadingBox() : notificationContent(),
        )
        )
       ],
    );
  }

  Widget loadingBox() {
    if (failed) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.wifi, size: 200, color: Colors.black26),
            Text("Oops! couldn't fetch notifcations",
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
                  fetchNotifications("desc");
                },
                child:
                Text("RELOAD", style: TextStyle(fontFamily: "Lato_Bolf")))
          ],
        ),
      );
    }
    return Center(child: SpinKitWave(
      color: Colors.blue,
      size: 20.0,
    ));
  }


  notificationContent(){
    if(start == 0 && notifications.length < 1){
      return Center(
        child: Column(
          children: [
            Icon(CupertinoIcons.bell, size: 200, color: Colors.black26),
            Text("You have no notifications yet.",
                style: TextStyle(
                    fontFamily: "Lato_Regular",
                    fontSize: 20,
                    color: Colors.black45))
          ],
        ),
      );
    }
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: ClassicHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              // body = Text(
              //   "pull up to load more data",
              //   style: TextStyle(fontFamily: "Lato_Regular"),
              // );
            } else if (mode == LoadStatus.loading) {
              body = SpinKitWave(
                color: Colors.blue,
                size: 20.0,
              );
            } else if (mode == LoadStatus.failed) {
              body = Text(
                "Load Failed! Click to retry!",
                style: TextStyle(fontFamily: "Lato_Regular"),
              );
            } else if (mode == LoadStatus.canLoading) {
              body = Text(
                "release to load more",
                style: TextStyle(fontFamily: "Lato_Regular"),
              );
            } else {
              body = Text(
                "No more Data",
                style: TextStyle(fontFamily: "Lato_Regular"),
              );
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(

        itemCount: notifications.length,
        itemBuilder: (context,index){
          return InkWell(
              onTap: (){


                if(notifications[index]['link']=='/post'){
                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SinglePost(feedId: notifications[index]['post_id'],)));
                }

                if(notifications[index]['link']=='/user' && notifications[index]['user_type'] != 'customer'){
                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: FashionDesignerProfile(userId: notifications[index]['user_id'],)));
                }
          },
          child: Container(
            color: Colors.white,
            child: ListTile(
            leading: CircleAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(
            appConfiguration.apiBaseUrl+''+notifications[index]['photo'])),
            title: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text:
                      notifications[index]['brand_name'] + ' ',
                      style: TextStyle(
                          fontFamily: "Lato_Black",
                          color: Colors.black,
                          fontSize: 14)),
                  TextSpan(
                      text: notifications[index]['message'],
                      style: TextStyle(
                          fontFamily: "Lato_Regular",
                          color: Colors.black,
                          fontSize: 14))
                ])),
            subtitle: Text(notifications[index]['duration'],style: TextStyle(fontFamily: "Lato_Bold"),),
            trailing: IconButton(icon: Icon(CupertinoIcons.ellipsis_vertical,size: 20), onPressed: (){
              showMaterialModalBottomSheet(
                expand: false,
                context: context,
                builder: (context) => Container(
                  height:!notifications[index]['message'].contains('Published') ? 100 :  200,
                  child: ListView(
                    padding: EdgeInsets.only(top: 8),
                    children: [
                      Center(child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                      ),),
                      Container(
                        child:!notifications[index]['message'].contains('Published') ? Container() :  InkWell(
                          onTap:(){
                            toggleNotificationSubscription(notifications[index]['sent_by']);
                            Navigator.pop(context);
                          },
                          child: ListTile(
                            title: Text(notifications[index]['subscribed']
                                != 'true' ? "Turn On Post Notifications" : "Turn Off Post Notifications",style:TextStyle                                                      (fontFamily: "Lato_Regular")),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap:(){
                          deleteNotifcation(notifications[index]['notification_id']);
                          Navigator.pop(context);
                        },
                        child: ListTile(
                          title: Text("Remove from notifications",style:TextStyle(fontFamily: "Lato_Regular")),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },),
            ),
          ),
          );
        },
      ),
    );
  }
}
