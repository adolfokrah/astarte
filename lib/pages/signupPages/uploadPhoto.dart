import 'dart:convert';
import 'dart:io';

import 'package:astarte/pages/signupPages/phoneVerification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:snack/snack.dart';

import '../../config.dart';

void main(){
  runApp(UploadPhoto());
}

class UploadPhoto extends StatefulWidget {
  final userInfo;

  UploadPhoto({Key key, @required this.userInfo}) : super(key: key);
  @override
  _UploadPhotoState createState() => _UploadPhotoState();
}

class _UploadPhotoState extends State<UploadPhoto> {
  Config appConfiguration = new Config();
  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.userInfo);
  }


  void processForm(){
    if(_image == null){
      Fluttertoast.showToast(
          msg: "Please select a photo",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }


    var data = widget.userInfo;
    // data['photoData'] = base64Encode(_image.readAsBytesSync());
    data['photoPath']  = _image.path;

    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: PhoneVerification(userInfo:data)));
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
      title: "Customer SignUp",
      home: Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        brightness: Brightness.light,
        leading: IconButton(icon: Icon(CupertinoIcons.back, color: Colors.black),onPressed: (){
          Navigator.pop(context);
        },),
      ),
        body: uploadPhotoContent()
      ),
    );
  }

  Widget uploadPhotoContent(){
    return Container(
      color: Colors.white,
      child: Center(
        child: ListView(
          // shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(child: Text("Upload a Photo",style: TextStyle(fontFamily: "Lato_Black",fontSize: 30))),
            ),
            Align(
              child: InkWell(
                onTap: (){
                  _showPicker(context);
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(200),
                    image:  _image != null  ? DecorationImage(
                      fit: BoxFit.fill,
                      image:Image.file(_image).image,
                    ) : null,
                  ),
                  child: _image == null ?  Icon(CupertinoIcons.profile_circled,size: 100, color: Colors.white,) : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(child: Text("One more step, help people notify you by uploading a photo",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 15),textAlign: TextAlign.center,)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: FlatButton(onPressed: (){
                processForm();
              },
                  child: Text("Register",style: TextStyle(color: Colors.white,fontFamily: "Lato_Bold"),),color: Colors.blue,minWidth: double.infinity,height: 50,shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.blue)
                  )),
            )
          ],
        ),
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
