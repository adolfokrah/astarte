import 'dart:convert';

import 'package:astarte/config.dart';
import 'package:astarte/pages/singleFeed.dart';
import 'package:astarte/pages/viewImage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

void main(){
  runApp(MyPosts());
}

class MyPosts extends StatefulWidget {

  var userId;
  MyPosts({Key key, @required this.userId}) : super(key: key);

  @override
  _MyPostsState createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  Config appConfiguration = Config();
  ScrollController _scrollController;
  var loading = true;
  var failed = false;
  var start  =0;
  var posts = [];
  var select = false;
  var selectedPosts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyPosts();
    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  //// ADDING THE SCROLL LISTINER
  _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      getMyPosts();
    }
  }

  Future getMyPosts()async{
    try{

      var url = appConfiguration.apiBaseUrl + 'fetchMyPosts.php';
      var data = {
        'user_id': widget.userId.toString(),
        'start': start.toString()
      };

      var response = await http.post(Uri.parse(url), body: data);
      
      var newPosts = jsonDecode(response.body);


      for(var i=0; i<newPosts.length; i++){
        newPosts[i]['selected'] = false;
      }

      var responseData = posts;
      var newFeeds = [];

      if(start == 0){
        newFeeds = newPosts;
      }else{
        newFeeds = []..addAll(responseData)..addAll(newPosts);
      }

      if(!mounted) return;
      setState(() {
        loading = false;
        start = jsonDecode(response.body).length > 0 ? start + 10 : start;
        posts = newFeeds;
      });
    }catch(e){
      print(e);
      setState(() {
        failed = true;
      });
    }
  }

  void _handleClick(e){
    if(!mounted) return;
    setState(() {
      selectedPosts = [];
    });
    if(e == "Deselect"){
      removeSeleted();
      return;
    }
    setState(() {
      select = true;
    });
  }

  void selectPost(index){
    var newPosts = posts;
    var nselectedPosts = selectedPosts;

    newPosts[index]['selected'] = !newPosts[index]['selected'];
    if(newPosts[index]['selected'] == true){
      nselectedPosts.add(newPosts[index]['feed_id']);
    }else{
      nselectedPosts.removeWhere((item)=>item == newPosts[index]['feed_id']);
    }

    if(!mounted) return;
    setState(() {
      posts=newPosts;
      selectedPosts = nselectedPosts;
    });

  }

  void removeSeleted(){
    var newPosts = posts;
    for(var i=0; i<newPosts.length; i++){
      newPosts[i]['selected'] = false;
    }
    setState(() {
      posts=newPosts;
      select = false;
    });
  }

  Future confirmRemove()async{
    if(selectedPosts.length < 1){
      Fluttertoast.showToast(
          msg: "Please select one or more images",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
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
                  new Text("Removing posts..."),
                ],
              ),
            ),
          );
        },
      );

      var url = appConfiguration.apiBaseUrl + 'removeMyPosts.php';
      var data = {
        'user_id': widget.userId.toString(),
        'posts': jsonEncode(selectedPosts).replaceAll("[", "(").replaceAll("]", ")")
      };

      var response = await http.post(Uri.parse(url), body: data);
      Navigator.of(context,rootNavigator: true).pop();
      var newPosts = posts;
      var nSelectedPosts = selectedPosts;
      for(var i=0; i<nSelectedPosts.length; i++){
        newPosts.removeWhere((item)=>item['feed_id'] == selectedPosts[i]);
      }
      setState(() {
        posts = newPosts;
        select = false;
      });

    }catch(e){
      print(e);
      Fluttertoast.showToast(
          msg: "Connection failed please try again later",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }

  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        title: "My Posts",
        home:Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            brightness: Brightness.light,
            title: Text("My Posts",style: TextStyle(fontFamily: "Lato_Black",color: Colors.black),),
            leading: IconButton(icon: Icon(select ? CupertinoIcons.clear: CupertinoIcons.back, color: Colors.black),onPressed: (){
              if(select){
                removeSeleted();
                setState(() {
                  selectedPosts = [];
                  select = false;
                });
                return;
              }
              Navigator.pop(context,selectedPosts);
            },),
          ),
          body: MyPostsBody(),
        )
    );
  }

  Widget MyPostsBody(){

    if(loading){
      return Container(
        color: Colors.white,
        child: Center(child: SpinKitWave(
          color: Colors.blue,
          size: 20.0,
        )),
      );
    }


    if(posts.length < 1){
      return Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(CupertinoIcons.doc_on_clipboard_fill, size: 100, color: Colors.black26),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text("You have no post yet",
                  style: TextStyle(
                      fontFamily: "Lato_Regular",
                      fontSize: 20,
                      color: Colors.black45)),
            ),

          ],
        ),
      );
    }

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
                  getMyPosts();
                },
                child:
                Text("TRY AGAIN", style: TextStyle(fontFamily: "Lato_Bolf")))
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: allPosts(),
    );
  }

  Widget allPosts(){
    return Container(
      child: Column(
        children: [
          Expanded(
            child: GridView(
              controller: _scrollController,
              padding: EdgeInsets.only(top:0,bottom: 0),
              // primary: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              children: List.generate(posts.length, (index) {
                return InkWell(
                  onTap: ()async{
                    if(select){
                      selectPost(index);
                      return;
                    }
                    var data = posts[index];
                    data['selectedImage'] = 0;
                    await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SinglePost(feedId: data['feed_id'])));
                    setState(() {
                      start = 0;
                    });
                    getMyPosts();
                  },
                  child: Container(
                    margin: EdgeInsets.all(1),
                    height: 100.0,
                    width: 100.0,
                    color: Colors.black12,
                    child: Stack(
                      children: [
                        Container(
                          child: CachedNetworkImage(
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover),
                              ),
                            ),
                            imageUrl: appConfiguration.apiBaseUrl+''+jsonDecode(posts[index]['images'])[0],
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child:iconBox(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          select ? Container(
            color: Colors.black12,
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: FlatButton(
              onPressed: (){
                confirmRemove();
              },
              child: Text("REMOVE"),
            ),
          ) : Container()
        ],
      ),
    );
  }

  Widget iconBox(index){
    if(select){
      return Padding(padding: EdgeInsets.all(5),child: Icon(posts[index]['selected'] == true ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,color: Colors.white,));
    }

    if(jsonDecode(posts[index]['images']).length > 1 ){
      return Padding(padding: EdgeInsets.all(5),child: Icon(CupertinoIcons.rectangle_fill_on_rectangle_fill,color: Colors.white,));
    }else{
      return Container();
    }
  }
}
