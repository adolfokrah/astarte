import 'dart:convert';
import 'package:astarte/pages/fashionDesignerProfile.dart';
import 'package:astarte/pages/savedPost.dart';
import 'package:astarte/pages/viewImage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snack/snack.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../config.dart';
import 'login.dart';

void main() {
  runApp(Feed());
}

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Config appConfiguration = Config();

  //my states
  var userId = "0";
  var start = 0;
  var end = 5;
  var nstart = 0;
  var loading = true;
  var order = 'desc';
  var feeds = [];
  var failed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }

  getNewFeeds() async {


    try {
    var mstart = start;
    if (order == 'asc') {
      mstart = nstart;
    }

    var position = await determinPosition();

    var dataM = {
      'userId': userId.toString(),
      'lat': position.latitude.toString(),
      'lng': position.longitude.toString(),
      'start': mstart.toString(),
      'end': end.toString(),
      'order': order
    };

    var url = appConfiguration.apiBaseUrl + 'fetch_new_feed.php';

    var response = await http.post(url, body: dataM);


    var data = jsonDecode(response.body);


    // var reversedList = data.reversed.toList();

    if (!mounted) return;
    setState(() {
      loading = false;
    });
    if (data.length < 1) {
      return;
    }

    if (order == 'asc' || start == 0) {
      if (!mounted) return;
      setState(() {
        nstart = int.parse(data[0]['feed_id']);
      });
    }

    var newFeeds = [];

    if (order == 'asc') {
      newFeeds = []..addAll(data)..addAll(feeds);
    } else {
      newFeeds = []..addAll(feeds)..addAll(data);
    }

    setState(() {
      feeds = newFeeds;
      start = start + end;
    });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      if (feeds.length < 1) {
        failed = true;
      } else {
        final bar = SnackBar(
            content: Text('Oops! Connection failed',
                style: TextStyle(fontFamily: "Lato_Bold")));
        bar.show(context);
      }
      print(e);
    }
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
        getNewFeeds();
        return;
      }else{
        getNewFeeds();
        return;
      }

    } catch (e) {
      print(e);
    }
  }

  Future<Position> determinPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }


    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchNewFeed() async {}

  void _onRefresh() async {
    // monitor network fetch
    // await getNewFeeds();
    // // if failed,use refreshFailed()
    if (!mounted) return;
    setState(() {
      order = 'asc';
    });
    await getNewFeeds();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    // await getNewFeeds();
    setState(() {
      order = 'desc';
    });
    await getNewFeeds();
    _refreshController.loadComplete();
  }

  void toggleLike(feedId) async{
    try{
      var myFeeds = feeds;

      if(userId =='0'){
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
        return;
      }

      for(var i=0; i<myFeeds.length; i++){
        if(myFeeds[i]['feed_id'] == feedId){
          if(myFeeds[i]['liked_by'] == 'liked'){
            myFeeds[i]['liked_by'] = '0';
            myFeeds[i]['likes'] = (int.parse(myFeeds[i]['likes']) - 1).toString();
          }else{
            myFeeds[i]['liked_by'] = 'liked';
            myFeeds[i]['likes'] = (int.parse(myFeeds[i]['likes']) + 1).toString();
          }
          break;
        }
      }
      if(!mounted) return;
      setState(() {
        feeds = myFeeds;
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
      var myFeeds = feeds;

      if(userId =='0'){
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
        return;
      }

      for(var i=0; i<myFeeds.length; i++){
        if(myFeeds[i]['feed_id'] == feedId){
          if(myFeeds[i]['favorite'] == 'true'){
            myFeeds[i]['favorite'] = '0';
          }else{
            myFeeds[i]['favorite'] = 'true';
          }
          break;
        }
      }
      if(!mounted) return;
      setState(() {
        feeds = myFeeds;
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


  void toggleNotificationSubscription(postedBy) async{
    try{
      var myFeeds = feeds;

      if(userId =='0'){
        //
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
        return;
      }

      Navigator.pop(context);


      var url = appConfiguration.apiBaseUrl + 'togglePostNotification.php';
      var response = await http.post(url, body: {
        'subscriber': userId.toString(),
        'posted_by': postedBy
      });


      var message = "";
      for(var i=0; i<myFeeds.length; i++){
        if(myFeeds[i]['posted_by'] == postedBy){
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
        feeds = myFeeds;
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

  void sharePost(index){

    Share.share('Wow, Check this is nice design from '+feeds[index]['brand_name']+' on the astarte app. https:/astarte.com/23423423423');
  }

  void toggleAllFavorites(selectedPosts){
    print(selectedPosts);
    var nfeeds = feeds;
    for(var i=0; i<nfeeds.length; i++){
      for(var x = 0; x<selectedPosts.length; x++){
        if(selectedPosts[x] == nfeeds[i]['feed_id']){
          nfeeds[i]['favorite'] = 'false';
        }
      }
    }
    setState(() {
      feeds = nfeeds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          toolbarHeight: 50,
          title: Text("Astarte",
              style: TextStyle(fontFamily: "Lato_Black", color: Colors.black)),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0.5,
          brightness: Brightness.light,
          actions: [
            IconButton(
              onPressed: ()async{
                if(userId == "0"){
                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
                  return;
                }
                var selectedPosts = await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SavedPost(userId: userId,)));
                toggleAllFavorites(selectedPosts);

              },
              icon: Icon(CupertinoIcons.heart, color: Colors.black),
            )
          ],
        ),
        Expanded(
            child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12, width: 1)),
            color: Colors.white,
          ),
          child: loading || failed
              ? loadingBox() : start == 0 && feeds.length < 1 ? noFeedsFound() : SmartRefresher(
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
                    itemBuilder: (context, index) {
                      return Container(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                appConfiguration.apiBaseUrl+''+feeds[index]['photo'])),
                                        onTap: (){
                                          if(userId == '0'){
                                            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
                                            return;
                                          }
                                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: FashionDesignerProfile(userId: feeds[index]['posted_by'],)));
                                        },
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            feeds[index]['brand_name'],
                                            style: TextStyle(
                                                fontFamily: "Lato_Bold"),
                                          )),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: feeds[index]['premium_account'] == 'true'? Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.blue,size:15) : null,
                                      )
                                    ],
                                  ),
                                  Container(
                                    width: 30,
                                    child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          CupertinoIcons.ellipsis_vertical,
                                          size: 20,
                                        ),
                                        color: Colors.black,
                                        onPressed: () {
                                          showMaterialModalBottomSheet(
                                            expand: false,
                                            context: context,
                                            builder: (context) => Container(
                                              height: feeds[index]['posted_by'] == userId ? 80 : 200,
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
                                                  InkWell(
                                                    onTap:(){
                                                      toggleNotificationSubscription(feeds[index]['posted_by']);
                                                      // Navigator.pop(context);
                                                    },
                                                    child:feeds[index]['posted_by'] == userId ? Container() : ListTile(
                                                      title: Text(feeds[index]['subscribed']
                                                      != 'true' ? "Turn On Post Notifications" : "Turn Off Post Notifications",style:TextStyle                                                      (fontFamily: "Lato_Regular")),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap:(){
    if(userId == '0') {
      Navigator.push(context,
          PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
      return;
    }
                                                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: FashionDesignerProfile(userId: feeds[index]['posted_by'],)));
                                                    },
                                                    child: feeds[index]['posted_by'] == userId ? Container() : ListTile(
                                                      title: Text("About This Fashion Designer",style:TextStyle(fontFamily: "Lato_Regular")),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap:(){
                                                      sharePost(index);
                                                    },
                                                    child: ListTile(
                                                      title: Text("Share Post to",style:TextStyle(fontFamily: "Lato_Regular")),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: double.parse(feeds[index]['size']),
                              child: new Swiper(
                                loop: false,
                                itemBuilder: (BuildContext context, int i) {
                                  return Stack(
                                    children:[
                                      InkWell(

                                        onTap:(){
                                          var data = feeds[index];
                                          data['selectedImage'] = i;
                                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewImage(data: data)));
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child:  CachedNetworkImage(
                                            imageBuilder: (context, imageProvider) => Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            imageUrl: appConfiguration.apiBaseUrl+''+jsonDecode(feeds[index]['images'])[i],
                                            placeholder: (context, url) => Container(
                                              color: Colors.black12,
                                            ),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                          ),

                                        ),
                                      )],
                                  );
                                },
                                itemCount:
                                    jsonDecode(feeds[index]['images']).length,
                                pagination:
                                    jsonDecode(feeds[index]['images']).length >
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
                                            feeds[index]['liked_by'] == 'liked'
                                                ? CupertinoIcons
                                                    .hand_thumbsup_fill
                                                : CupertinoIcons.hand_thumbsup,
                                            color: feeds[index]['liked_by'] ==
                                                    'liked'
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                          onPressed: (){
                                            toggleLike(feeds[index]['feed_id']);
;                                          }),
                                      IconButton(
                                          icon: Icon(CupertinoIcons.paperplane
                                          ),
                                          onPressed: (){
                                            sharePost(index);
                                          })
                                    ],
                                  ),
                                  IconButton(
                                      icon: Icon(
                                        feeds[index]['favorite'] == 'true'
                                            ? CupertinoIcons
                                            .heart_fill
                                            : CupertinoIcons.heart,
                                        color: Colors.black
                                      ),
                                      onPressed: (){
                                        toggleFavorite(feeds[index]['feed_id']);
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
                                      double.parse(feeds[index]['likes']) != 1
                                          ? feeds[index]['likes'] + ' likes'
                                          : feeds[index]['likes'] + ' like',
                                      style:
                                          TextStyle(fontFamily: "Lato_Black")),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text:
                                              feeds[index]['brand_name'] + ' ',
                                          style: TextStyle(
                                              fontFamily: "Lato_Black",
                                              color: Colors.black,
                                              fontSize: 12)),
                                      TextSpan(
                                          text: feeds[index]['description'],
                                          style: TextStyle(
                                              fontFamily: "Lato_Regular",
                                              color: Colors.black,
                                              fontSize: 12))
                                    ])),
                                  ),
                                ],
                              ),
                            )
                          ]));
                    },
                    itemCount: feeds.length,
                  ),
                ),
        ))
      ],
    );
  }


  Widget noFeedsFound(){
    return Center(
      child: Column(
        children: [
          Icon(Icons.warning_amber_outlined, size: 200, color: Colors.black26),
          Text("Sorry!, no feeds found in your location",
              style: TextStyle(
                  fontFamily: "Lato_Regular",
                  fontSize: 20,
                  color: Colors.black45)),
        ],
      ),
    );
  }
  Widget loadingBox() {
    if (failed) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.wifi, size: 200, color: Colors.black26),
            Text("Oops! couldn't fetch feeds",
                style: TextStyle(
                    fontFamily: "Lato_Regular",
                    fontSize: 20,
                    color: Colors.black45)),
            CupertinoButton(
                onPressed: () {
                  if (!mounted) return;
                  setState(() {
                    loading = true;
                    failed = false;
                  });
                  getNewFeeds();
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
}
