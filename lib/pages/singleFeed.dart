import 'dart:convert';

import 'package:astarte/pages/viewImage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:snack/snack.dart';
import '../config.dart';
import 'fashionDesignerProfile.dart';
import 'login.dart';

void main(){
  runApp(SinglePost());
}

class SinglePost extends StatefulWidget {

  final feedId;

  SinglePost({Key key, @required this.feedId}) : super(key: key);

  @override
  _SinglePostState createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  Config appConfiguration = new Config();
  var loading = true;
  var feed;
  var userId = '0';
  var failed = false;
  var nothing = false;

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
        });
        getFeedDetails();
        return;
      }else{
        getFeedDetails();
      }

    } catch (e) {
      print(e);
    }
  }

  void toggleLike(feedId) async{
    try{
      var myFeeds = feed;

      if(userId =='0'){
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
        return;
      }

      if(myFeeds['liked_by'] == 'liked'){
        myFeeds['liked_by'] = '0';
        myFeeds['likes'] = (int.parse(myFeeds['likes']) - 1).toString();
      }else{
        myFeeds['liked_by'] = 'liked';
        myFeeds['likes'] = (int.parse(myFeeds['likes']) + 1).toString();
      }
      if(!mounted) return;
      setState(() {
        feed = myFeeds;
      });

      var url = appConfiguration.apiBaseUrl + 'toggleLike.php';
      var response = await http.post(url, body: {
        'userId': userId.toString(),
        'feedId': feedId
      });

      print(response.body);
    }catch(e){
      print(e);
      final bar = SnackBar(
          content: Text('Oops! connection failed',
              style: TextStyle(fontFamily: "Lato_Bold")));
      bar.show(context);
    }
  }

  void toggleFavorite(feedId) async{
    try{
      var myFeeds = feed;

      if(userId =='0'){
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
        return;
      }

      if(myFeeds['favorite'] == 'true'){
        myFeeds['favorite'] = '0';
      }else{
        myFeeds['favorite'] = 'true';
      }

      if(!mounted) return;
      setState(() {
        feed = myFeeds;
      });

      var url = appConfiguration.apiBaseUrl + 'togglefavorites.php';
      var response = await http.post(url, body: {
        'userId': userId.toString(),
        'feedId': feedId
      });

      print(response.body);
    }catch(e){
      print(e);
      final bar = SnackBar(
          content: Text('Oops! connection failed',
              style: TextStyle(fontFamily: "Lato_Bold")));
      bar.show(context);
    }
  }

  Future deleteFeed(feedId)async{
    try {
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

      var url = appConfiguration.apiBaseUrl + 'deleteFeed.php';
      var data = {
        'feed_id': widget.feedId.toString()
      };
      var response = await http.post(url, body: data);
      Navigator.of(context,rootNavigator: true).pop();
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Feed removed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

    }catch(e){
      Navigator.pop(context);
      print(e);
    }
  }

  void sharePost(){
    Share.share('Wow, Check this is nice design from '+feed['brand_name']+' on the astarte app. https:/astarte.com/23423423423');
  }

  Future getFeedDetails()async{
    try{
      var url = appConfiguration.apiBaseUrl + 'getSingleFeed.php';
      var data = {
        'feed_id': widget.feedId.toString(),
        'user_id': userId.toString()
      };

      var response = await http.post(url, body: data);

      var newFeed = jsonDecode(response.body);
      if(newFeed[0]['feed_id'] == null){
        setState(() {
          nothing = true;
        });
        return;
      }
      if(!mounted) return;
      setState(() {
        loading = false;
        feed = newFeed[0];
      });
    }catch(e){
      setState(() {
        failed = true;
      });
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
      elevation: 1,
      brightness: Brightness.light,
      leading: IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.black),onPressed: (){
        Navigator.pop(context);
      },),
    ),
    body:singlePostContent()
    ));
  }

  Widget singlePostContent(){
    if (nothing){
      return Center(
        child: Column(
          children: [
            Icon(Icons.warning_amber_outlined, size: 200, color: Colors.black26),
            Text("Oops! this feed is unavailable",
                style: TextStyle(
                    fontFamily: "Lato_Regular",
                    fontSize: 20,
                    color: Colors.black45)),
          ],
        ),
      );
    }
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
                  getUserDetails();
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
    }else{
      return Container(
        padding: EdgeInsets.only(top: 20),
          child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            child: CircleAvatar(
                                radius: 16,
                                backgroundImage: CachedNetworkImageProvider(
                                    appConfiguration.apiBaseUrl+''+feed['photo'])
                            ),
                            onTap: (){
                              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: FashionDesignerProfile(userId: feed['posted_by'],)));
                            },
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                feed['brand_name'],
                                style: TextStyle(
                                    fontFamily: "Lato_Bold"),
                              )),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: feed['premium_account'] == 'true'? Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.blue,size:15) : null,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: double.parse(feed['size']),
                  child: new Swiper(
                    loop: false,
                    itemBuilder: (BuildContext context, int i) {
                      return Stack(
                        children:[
                          InkWell(

                            onTap:(){
                              var data = feed;
                              data['selectedImage'] = i;
                              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewImage(data: data)));
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: CachedNetworkImage(
                                imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                imageUrl: appConfiguration.apiBaseUrl+''+jsonDecode(feed['images'])[i],
                                placeholder: (context, url) => SpinKitWave(
                                  color: Colors.blue,
                                  size: 20.0,
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                          )],
                      );
                    },
                    itemCount:
                    jsonDecode(feed['images']).length,
                    pagination:
                    jsonDecode(feed['images']).length >
                        1
                        ? new SwiperPagination()
                        : null,
                    control: null,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              icon: Icon(
                                feed['liked_by'] == 'liked'
                                    ? CupertinoIcons
                                    .hand_thumbsup_fill
                                    : CupertinoIcons.hand_thumbsup,
                                color: feed['liked_by'] ==
                                    'liked'
                                    ? Colors.red
                                    : Colors.black,
                              ),
                              onPressed: (){
                                toggleLike(feed['feed_id']);
                                ;                                          }),
                          IconButton(
                              icon: Icon(CupertinoIcons.paperplane
                              ),
                              onPressed: (){
                                sharePost();
                              })
                        ],
                      ),
                      IconButton(
                          icon: Icon(
                              feed['favorite'] == 'true'
                                  ? CupertinoIcons
                                  .bookmark_fill
                                  : CupertinoIcons.bookmark,
                              color: Colors.black
                          ),
                          onPressed: (){
                            toggleFavorite(feed['feed_id']);
                          })
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                      left: 10, right: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          double.parse(feed['likes']) != 1
                              ? feed['likes'] + ' likes'
                              : feed['likes'] + ' like',
                          style:
                          TextStyle(fontFamily: "Lato_Black")),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text:
                                  feed['brand_name'] + ' ',
                                  style: TextStyle(
                                      fontFamily: "Lato_Black",
                                      color: Colors.black,
                                      fontSize: 12)),
                              TextSpan(
                                  text: feed['description'],
                                  style: TextStyle(
                                      fontFamily: "Lato_Regular",
                                      color: Colors.black,
                                      fontSize: 12))
                            ])),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child:userId == feed['posted_by'] ?  Column(
                          children: [
                            Text(feed['feed_status'].toUpperCase(), style: TextStyle(fontFamily: "Lato_Bold",color: feed['feed_status'] == 'published' ? Colors.green : feed['feed_status'] == 'rejected' ? Colors.red : Colors.orange),),
                            FlatButton(onPressed: (){
                              deleteFeed(widget.feedId);
                            },
                            child: Text("Remove Post",style: TextStyle(fontFamily: "Lato_Bold",color:Colors.red),),
                              minWidth: double.infinity,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Colors.red)
                                )
                            )
                          ],
                        ) : Container(),
                      )
                    ],
                  ),
                )
              ]));
    }
  }
}
