import 'dart:convert';
import 'dart:io';

import 'package:astarte/config.dart';
import 'package:astarte/pages/reviewSentPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  runApp(SendReviews());
}

class SendReviews extends StatefulWidget {

  final userId;

  SendReviews({Key key, @required this.userId}) : super(key: key);

  @override
  _SendReviewsState createState() => _SendReviewsState();
}

class _SendReviewsState extends State<SendReviews> {
  Config appConfiguration = new Config();
  TextEditingController feedBack = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  var loading = false;
  var failed = false;
  var userData;
  var rate = 0;
  var userId = "0";

  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }


  getUserDetails() async {
    try {
      if(!mounted) return;
      setState(() {
        loading = true;
      });
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
        getFashionDesignerDetails();
        return;
      }else{
        getFashionDesignerDetails();
      }

    } catch (e) {
      print(e);
    }
  }


  Future getFashionDesignerDetails()async{
    try{
      if(!mounted) return;
      setState(() {
        loading = true;
      });
      var url = appConfiguration.apiBaseUrl + 'getFashionDesingerProfile.php';
      var data = {
        'user_id': widget.userId.toString()
      };
      var response = await http.post(Uri.parse(url), body: data);

      if(!mounted) return;
      setState(() {
        loading = false;
        userData = jsonDecode(response.body)['userInfo'];
      });
    }catch(e){
      print(e);
      if(!mounted) return;
      setState(() {
        failed = true;
      });
    }
  }

  Future sendFeedBack() async{
      if(_formKey.currentState.validate()){
          if(rate < 1){
            Fluttertoast.showToast(
                msg: "Please rate the fashion designer",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0
            );
            return;
          }


          try{

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

            var url = appConfiguration.apiBaseUrl + 'rateFashionDesigner.php';
            var data = {
              'user_id': userData['user_id'].toString(),
              'sent_by': userId,
              'rating': rate.toString(),
              'message': feedBack.text,
              'review_id': '0'
            };

            var request = http.MultipartRequest('POST', Uri.parse(url));
            request.files.add(await http.MultipartFile.fromPath('attached_photo',_image.path));
            request.fields.addAll(data);
            var res = await request.send();
            var response = await res.stream.bytesToString();

            Navigator.of(context,rootNavigator: true).pop();

            // print(response); return;
            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rightToLeft, child: ReviewSentPage()));

          }catch(e){
            print(e);
            Fluttertoast.showToast(
                msg: "Connection failed",
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
  }


  Future getImage(from) async {
    final pickedFile = await picker.getImage(source: from == 'gallery' ? ImageSource.gallery : ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _cropImage(File(pickedFile.path));
      } else {
        print('No image selected.');
      }
    });
  }

  Future<Null> _cropImage(image) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {

      setState(() {
        _image = croppedFile;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        title: "Send Feedback",
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              brightness: Brightness.light,
              centerTitle: false,
              title: Text("Send Feedback", style: TextStyle(color: Colors.black, fontFamily: "Lato_Black"),),
              leading: IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.black),onPressed: (){
                Navigator.pop(context);
              },),
            ),
            body:sendReviewContent()
        ));
  }

  Widget sendReviewContent(){
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
                Text("RELOAD", style: TextStyle(fontFamily: "Lato_Bolf")))
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

    return Container(
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: CircleAvatar(
                        radius: 40,
                        backgroundImage: CachedNetworkImageProvider(
                            appConfiguration.apiBaseUrl+''+userData['photo'])),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(child: Text("How was your experience with "+userData['brand_name'],style: TextStyle(fontFamily: "Lato_Regular",fontSize: 15),)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: 250,
                    color: Colors.blue,
                    child:  rating(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: TextFormField(
                    controller: feedBack,
                    maxLines: 8,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(15),
                        fillColor: Colors.black12,
                        filled: true,
                        hintText: "Your Feedback here",
                        hintStyle: TextStyle(fontFamily: "Lato_Regular",fontSize: 15.0),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            )
                        )
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your feedback';
                      }
                      if(value.length < 10){
                        return 'Your feedback is very short';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: InkWell(
                    onTap: (){
                      _showPicker(context);
                    },
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(5)
                      ),
                        child: Center(
                          child: _image != null ? Stack(
                            children: [
                              Center(
                                child: Image.file(_image),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: (){
                                    setState(() {
                                      _image = null;
                                    });
                                  },
                                  icon: Icon(CupertinoIcons.delete),
                                ),
                              )
                            ],
                          ): Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.camera,size: 60,color: Colors.black12,),
                              Text("Add Photo (optional)", style: TextStyle(fontFamily: "Lato_Regular",fontSize: 16,color: Colors.black45),)
                            ],
                          ),
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FlatButton(onPressed: (){
                    sendFeedBack();
                  },
                      child: Text("Send Feedback",style: TextStyle(color: Colors.white,fontFamily: "Lato_Bold"),),color: Colors.blue,minWidth: double.infinity,height: 50,shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.blue)
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget rating(){
    List <Widget> list = List<Widget>();

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: Icon(rate > 0 ? Icons.star : Icons.star_border,
              color: rate > 0 ? Colors.orange : Colors.black45, size: 37,),
            onPressed: () {
              setState(() {
                rate = 1;
              });
            },
          ),
          IconButton(
            icon: Icon(rate > 1 ? Icons.star : Icons.star_border,
              color: rate > 1 ? Colors.orange : Colors.black45,size: 37,),
            onPressed: () {
              setState(() {
                rate = 2;
              });
            },
          ),
          IconButton(
            icon: Icon(rate > 2 ? Icons.star : Icons.star_border,
              color: rate > 2 ? Colors.orange : Colors.black45,size: 37,),
            onPressed: () {
              setState(() {
                rate = 3;
              });
            },
          ),
          IconButton(
            icon: Icon(rate > 3 ? Icons.star : Icons.star_border,
              color: rate > 3 ? Colors.orange : Colors.black45,size: 37,),
            onPressed: () {
              setState(() {
                rate = 4;
              });
            },
          ),
          IconButton(
            icon: Icon(rate > 4 ? Icons.star : Icons.star_border,
              color: rate > 4 ? Colors.orange : Colors.black45,size: 37,),
            onPressed: () {
              setState(() {
                rate = 5;
              });
            },
          )
        ],
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  Center(child: Container(
                    width: 50,
                    height: 5,
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                  ),),
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        getImage('gallery');
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      getImage('camera');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
