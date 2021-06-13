import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:transparent_image/transparent_image.dart';

import '../config.dart';

void main(){
  runApp(ViewImage());
}

class ViewImage extends StatefulWidget {
  final data;

  ViewImage({Key key, @required this.data}) : super(key: key);

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  Config appConfiguration = Config();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        title: "Login",
        home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          brightness: Brightness.light,
          leading: IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.white),onPressed: (){
          Navigator.pop(context);
        },),
        ),
          body:Container(
            color: Colors.black,
            child: Stack(
              children: [
                new Swiper(
                  loop: false,
                  index: widget.data['selectedImage'],
                  itemBuilder: (BuildContext context, int i) {
                    return Stack(
                      children:[
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          child:  CachedNetworkImage(
                            imageUrl: appConfiguration.apiBaseUrl+''+jsonDecode(widget.data['images'])[i],
                            placeholder: (context, url) => SpinKitWave(
                              color: Colors.blue,
                              size: 20.0,
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        )
                      ],
                    );
                  },
                  itemCount:
                  jsonDecode(widget.data['images']).length,
                  pagination:
                  jsonDecode(widget.data['images']).length >
                      1
                      ? new SwiperPagination()
                      : null,
                  control: null,
                ),
                Container(
                  height: double.infinity,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      color: Colors.black45,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20,bottom: 60, right: 20,top: 10),
                        child: Text(widget.data['description'],style: TextStyle(fontFamily: "Lato_Regular",color:Colors.white,fontSize: 17),),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
    )
    );
  }
}
