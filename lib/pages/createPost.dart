import 'dart:convert';

import 'package:astarte/pages/singleFeed.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

import '../config.dart';

void main(){
  runApp(CreatePost());
}

class CreatePost extends StatefulWidget {
  final images;

  CreatePost({Key key, @required this.images}) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  TextEditingController caption = TextEditingController();

  Future createPost()async{
    try{
      if(caption.text.isEmpty){
        Fluttertoast.showToast(
            msg: "Please add some caption",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }


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
                  new Text("Please wait...."),
                ],
              ),
            ),
          );
        },
      );

      var url = appConfiguration.apiBaseUrl + 'createPost.php';

      List<MultipartFile> multipartImageList = new List<MultipartFile>();
      for (Asset asset in widget.images) {
        ByteData byteData = await asset.getByteData();
        List<int> imageData = byteData.buffer.asUint8List();
        MultipartFile multipartFile = new MultipartFile.fromBytes(
          imageData,
          filename: asset.name,
          contentType: new MediaType("image", "jpg"),
        );
        multipartImageList.add(multipartFile);
      }

      SharedPreferences storage = await SharedPreferences.getInstance();
      String userDetails = storage.getString('userDetails');
      var userId = jsonDecode(userDetails)['user_id'];

      FormData formData = FormData.fromMap({
        "multipartFiles": multipartImageList,
        "description": caption.text,
        'feed_id': 0,
        'posted_by': userId.toString(),
        'status':'published'
      });

      Dio dio = new Dio();
      var response = await dio.post(url, data: formData);


      Navigator.of(context,rootNavigator: true).pop();


      Fluttertoast.showToast(
          msg: "Post published",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );


      // print(response.data); return;
      var data = jsonDecode(response.data);
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rightToLeft, child: SinglePost(feedId: data['feed_id'])));
    }on DioError catch (e){
      print(e);
      Navigator.of(context,rootNavigator: true).pop();
      Fluttertoast.showToast(
          msg: "Connection failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }


  Config appConfiguration = new Config();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: appConfiguration.appColor),
      title: "Login",
      home: Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Text("Create A Post",style: TextStyle(fontFamily: "Lato_Black",fontSize: 20,color: Colors.black),),
      brightness: Brightness.light,
      leading: IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.black),onPressed: (){
        Navigator.pop(context);
      },),
          actions: [
            IconButton(
              icon: Icon(Icons.send,color:Colors.black),
              onPressed: () {
                createPost();
              },
            )
          ],
       ),
        body: createPostBody(),
      )
    );
  }

  Widget createPostBody(){
    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: widget.images.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context,index){
                Asset asset = widget.images[index];
                return Container(
                  margin: EdgeInsets.only(left: 5),
                  width: 250,
                  height: 250,
                  child: AssetThumb(
                    asset: asset,
                    width: 300,
                    height: 300,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: caption,
              maxLines: 10,
              style: TextStyle(
                fontFamily: "Lato_Regular",
                fontSize: 20,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Add Caption",
                hintStyle: TextStyle(
                  fontFamily: "Lato_Regular",
                  fontSize: 20,
                  color: Colors.black12,

                ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      )
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      )
                  )
              ),
            ),
          )
        ],
      ),
    );
  }

}
