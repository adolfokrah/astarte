import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';
import '../config.dart';

void main(){
  runApp(EditProfile());
}

class EditProfile extends StatefulWidget {
  final userDetails;

  EditProfile({Key key, @required this.userDetails}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Config appConfiguration = new Config();
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullName = TextEditingController();
  TextEditingController email = TextEditingController();
  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fullName.text = widget.userDetails['full_name'];
    email.text = widget.userDetails['email'];
  }


  void processForm()async{

  try{

    if(_formKey.currentState.validate()){
      var data = {};
      data['email'] = email.text;
      data['full_name'] = fullName.text;
      data['password'] =  '';
      data['user_id']  = widget.userDetails['user_id'].toString();
      data['photo'] = widget.userDetails['photo'];


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
                  new Text("updating profile..."),
                ],
              ),
            ),
          );
        },
      );

      var url = appConfiguration.apiBaseUrl + 'updateUserProfile.php';
      // var response = await http.post(Uri.parse(url), body:data);


      Map<String, String> myMap = new Map<String, String>.from(data);


      var request = http.MultipartRequest('POST', Uri.parse(url));
      if(_image != null){
        request.files.add(await http.MultipartFile.fromPath('photo',_image.path));
      }

      request.fields.addAll(myMap);
      var res = await request.send();
      var response = await res.stream.bytesToString();



      Navigator.of(context,rootNavigator: true).pop();
      if(response == '0'){
        Fluttertoast.showToast(
            msg: "Sorry! it seems you already have an account with us.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }

      Fluttertoast.showToast(
          msg: "Profile updated.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      SharedPreferences storage = await SharedPreferences.getInstance();
      storage.setString("userDetails", response);

      if(_image != null){
        Phoenix.rebirth(context);
      }
    }
  }catch(e){
    Navigator.of(context,rootNavigator: true).pop();
    print(e);
    Fluttertoast.showToast(
        msg: "Connection failed.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
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
        title: "Edit Profile",
        home:Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              centerTitle: false,
              title: Text("Edit Profile",style: TextStyle(color: Colors.black,fontFamily: "Lato_Bold"),),
              brightness: Brightness.light,
              leading: IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.black),onPressed: (){
                Navigator.pop(context);
              },),
              actions: [
                IconButton(
                  onPressed: (){
                    processForm();
                  },
                  icon: Icon(Icons.check,color: appConfiguration.appColor),
                )
              ],
            ),
          body: editProfileContent(),
        )
    );
  }

  Widget editProfileContent(){
    return Container(
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0,bottom: 20),
              child:Align(
                child: InkWell(
                  onTap: (){
                    _showPicker(context);
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image:  _image != null ? Image.file(_image).image : CachedNetworkImageProvider(
                            appConfiguration.apiBaseUrl+''+widget.userDetails['photo']),
                      ),
                    ),
                  ),
                ),
              )

            ),
            Center(
              child: InkWell(
                  onTap: (){
                    _showPicker(context);
                  },
                  child: Text("Change Profile Picture",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 18,color: Colors.blueAccent),)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                validator: (value){
                  if(value.isEmpty){
                    return 'Please enter your full name';
                  }
                  return null;
                },
                  controller: fullName,
                  decoration: InputDecoration(
                     labelText: "Full Name"
                  ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 0, right: 20),
              child: TextFormField(
                validator: (value){
                  if(!isEmail(value)){
                    return "Please enter a valid email address";
                  }
                  return null;
                },
                controller: email,
                decoration: InputDecoration(
                    labelText: "Email"
                ),
              ),
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

