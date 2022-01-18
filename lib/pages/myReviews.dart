import 'dart:convert';

import 'package:astarte/config.dart';
import 'package:astarte/pages/viewImage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';


void main(){
  runApp(MyReviews());
}

class MyReviews extends StatefulWidget {

  final userId;

  MyReviews({Key key, @required this.userId}) : super(key: key);

  @override
  _MyReviewsState createState() => _MyReviewsState();
}

class _MyReviewsState extends State<MyReviews> {
  Config appConfiguration = new Config();
  var myReviews = [];
  var loading = false;
  var failed = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchReviews();
  }


  Future fetchReviews()async{
    try{
      if(!mounted) return;
      setState(() {
        loading = true;
      });
      var url = appConfiguration.apiBaseUrl + 'fetchUserReviews.php';
      var data = {
        'user_id': widget.userId.toString()
      };
      var response = await http.post(Uri.parse(url), body: data);
      if(!mounted) return;
      setState(() {
        loading = false;
        myReviews  = []..addAll(['hl'])..addAll(jsonDecode(response.body));
      });
    }catch(e){
      if(!mounted) return;
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
        title: "My Reviews",
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              brightness: Brightness.light,
              centerTitle: false,
              title: Text("My Reviews", style: TextStyle(color: Colors.black, fontFamily: "Lato_Black"),),
              leading: IconButton(icon: Icon(CupertinoIcons.back, color: Colors.black),onPressed: (){
                Navigator.pop(context);
              },),
            ),
            body:myReviewsContent()
        ));
  }

  Widget myReviewsContent(){

    if (failed){
      return Center(
        child: Column(
          children: [
            Icon(Icons.wifi, size: 200, color: Colors.black26),
            Text("Oops! couldn't fetch reviews",
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
                  fetchReviews();
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

     if(myReviews.length < 2){
       return Container(
         color: Colors.white,
         child: Column(
           children: [
             Padding(
               padding: const EdgeInsets.all(2.0),
               child: Center(child: Icon(CupertinoIcons.chat_bubble_2,size: 200,color: Colors.black12,)),
             ),
             Padding(
               padding: const EdgeInsets.all(2.0),
               child: Center(child: Text("There are no Reviews yet", style: TextStyle(fontFamily: "Lato_Regular",fontSize: 15))),
             ),
             Padding(
               padding: const EdgeInsets.all(2.0),
               child: Center(child: Text("Ask your customers to  leave feedback about you.",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 15),)),
             ),
             Padding(
               padding: const EdgeInsets.all(2.0),
               child: Center(child: Text("Copy the link and send them.",style: TextStyle(fontFamily: "Lato_Black",fontSize: 15),)),
             ),
             SizedBox(
               width: 300,
               child: RaisedButton(
                 onPressed: (){
                   FlutterClipboard.copy('hello flutter friends').then(( value ) => {
                     Fluttertoast.showToast(
                         msg: "Link Copied",
                         toastLength: Toast.LENGTH_SHORT,
                         gravity: ToastGravity.BOTTOM,
                         timeInSecForIosWeb: 1,
                         backgroundColor: Colors.black,
                         textColor: Colors.white,
                         fontSize: 16.0
                     )
                   });
                 },
                 child: Text("Copy my link",style: TextStyle(fontSize: 16,color: Colors.white),),
                 color: Colors.blueAccent,
               ),
             )
           ],
         ),
       );
     }else{
       return Container(
         color: Colors.white,
         child: ListView.separated(
           padding: EdgeInsets.only(top: 0),
           separatorBuilder: (context,index){
             return Divider();
           },
           itemCount: myReviews.length,
           itemBuilder: (context,index){
             if(index == 0){
               return Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: Column(
                   children: [
                     Padding(
                       padding: const EdgeInsets.all(2.0),
                       child: Center(child: Text("Ask your customers to  leave feedback about you.",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 15),)),
                     ),
                     Padding(
                       padding: const EdgeInsets.all(2.0),
                       child: Center(child: Text("Copy the link and send them.",style: TextStyle(fontFamily: "Lato_Black",fontSize: 15),)),
                     ),
                     SizedBox(
                       width: 300,
                       child: RaisedButton(
                         onPressed: (){
                           FlutterClipboard.copy('hello flutter friends').then(( value ) => {
                             Fluttertoast.showToast(
                                 msg: "Link Copied",
                                 toastLength: Toast.LENGTH_SHORT,
                                 gravity: ToastGravity.BOTTOM,
                                 timeInSecForIosWeb: 1,
                                 backgroundColor: Colors.black,
                                 textColor: Colors.white,
                                 fontSize: 16.0
                             )
                           });
                         },
                         child: Text("Copy my link",style: TextStyle(fontSize: 16,color: Colors.white),),
                         color: Colors.blueAccent,
                       ),
                     )
                   ],
                 ),
               );
             }
             return ListTile(
               title: Row(
                 children: [
                   Padding(
                     padding: const EdgeInsets.only(right: 8.0),
                     child: CircleAvatar(
                         radius: 15,
                         backgroundImage: CachedNetworkImageProvider(
                             appConfiguration.apiBaseUrl+''+myReviews[index]['photo'])),
                   ),
                   Text(myReviews[index]['full_name'],style: TextStyle(fontFamily: "Lato_Bold"),)
                 ],
               ),
               subtitle: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Padding(
                     padding: EdgeInsets.only(top: 10),
                     child: stars(int.parse(myReviews[index]['rating'])),
                   ),
                   Padding(
                     padding: EdgeInsets.only(left:0),
                     child: Text(myReviews[index]['message'],style: TextStyle(fontFamily: "Lato_Regular"),),
                   ),
                   InkWell(
                     onTap: (){
                       if(myReviews[index]['attached_photo'] == ''){
                         return;
                       }
                       var data = {
                         'description': myReviews[index]['message'],
                         'selectedImage' : 0
                       };
                       var ndata = jsonEncode([myReviews[index]['attached_photo']]);
                       data['images'] = ndata;
                       Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewImage(data: data)));
                     },
                     child: Padding(
                       padding: EdgeInsets.only(top: 10),
                       child: Container(
                         height: myReviews[index]['attached_photo'] == '' ? 0 : 120,
                         width: 100,
                         child: myReviews[index]['attached_photo'] == '' ? null : CachedNetworkImage(
                           imageBuilder: (context, imageProvider) => Container(
                             decoration: BoxDecoration(
                               image: DecorationImage(
                                   image: imageProvider,
                                   fit: BoxFit.contain),
                             ),
                           ),
                           imageUrl: appConfiguration.apiBaseUrl+''+myReviews[index]['attached_photo'],
                           placeholder: (context, url) => SpinKitWave(
                             color: Colors.blue,
                             size: 20.0,
                           ),
                           errorWidget: (context, url, error) => Icon(Icons.error),
                         ),
                       ),
                     ),
                   )
                 ],
               ),
               trailing: Text(myReviews[index]['date'], style: TextStyle(fontFamily: "Lato_Regular")),
             );
           },
         ),
       );
     }
  }
}

Widget stars(rate){
  List<Widget> list = List();

  for(var i=0; i<rate; i++){
    list.add(Icon(Icons.star, color: Colors.orange,size:15));
  }

  for(var i=0; i<(5-rate); i++){
    list.add(Icon(Icons.star, color: Colors.black45,size:15));
  }

  return Row(
    children: list,
  );
}
