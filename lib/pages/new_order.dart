import 'dart:convert';
import 'dart:io';

import 'package:astarte/config.dart';
import 'package:astarte/pages/location_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';
import 'package:http/http.dart' as http;


class NewOrder extends StatefulWidget {
  const NewOrder({Key key}) : super(key: key);

  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController senderName = TextEditingController();
  TextEditingController senderNumber = TextEditingController();
  TextEditingController senderLocation = TextEditingController();

  TextEditingController recipientName = TextEditingController();
  TextEditingController recipientNumber = TextEditingController();
  TextEditingController recipientLocation = TextEditingController();

  TextEditingController items = TextEditingController();
  var senderLat,senderLng,recipientLat,recipientLng;
  File _image;
  final picker = ImagePicker();
  Config appConfiguration = new Config();

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

  Future<void> placeOrder()async{
    try{
      if(_formKey.currentState.validate()){
        var data = {};
        SharedPreferences storage = await SharedPreferences.getInstance();
        String userDetails = storage.getString('userDetails');

        data['user_id'] = jsonDecode(userDetails)['user_id'].toString();
        data['sender_name'] = senderName.text;
        data['sender_number'] = senderNumber.text;
        data['pickup_location'] = senderLocation.text;
        data['recipient_name'] = recipientName.text;
        data['recipient_number'] = recipientNumber.text;
        data['dropoff_address'] = recipientLocation.text;
        data['items'] = items.text;
        data['pickup_cordinates'] = '${senderLat},${senderLng}';
        data['dropoff_cordinates'] = '${recipientLat},${recipientLng}';

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

        Map<String, String> myMap = new Map<String, String>.from(data);
        var url = appConfiguration.apiBaseUrl + 'place_order.php';
        var request = http.MultipartRequest('POST', Uri.parse(url));
        if(_image != null){
          request.files.add(await http.MultipartFile.fromPath('item_photo',_image.path));
        }

        request.fields.addAll(myMap);
        var res = await request.send();
        var response = await res.stream.bytesToString();



        Navigator.of(context,rootNavigator: true).pop();

        Fluttertoast.showToast(
            msg: "Order placed.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.pop(context);

      }
    }catch(e){
      Navigator.of(context,rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(CupertinoIcons.back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text("New Order",
            style: TextStyle(fontFamily: "Lato_Black", color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        brightness: Brightness.light
      ),
      body: content(),
    );
  }
  Widget content(){
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top:20),
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.blueGrey,
                      width: 1,
                    )
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextFormField(
                        controller: senderName,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            fillColor: Colors.black12,
                            filled: true,
                            hintText: "Sender Name",
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
                            return 'Please enter your sender name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15,right:15,bottom:15),
                      child: TextFormField(
                        controller: senderNumber,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            fillColor: Colors.black12,
                            filled: true,
                            hintText: "Sender Phone Number",
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
                            return 'Please enter your phone number';
                          }

                          if(!isNumeric(value)){
                            return "Please enter a valid phone number";
                          }

                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15,right:15,bottom:15),
                      child: TextFormField(
                        controller: senderLocation,
                        readOnly: true,
                        onTap: ()async{
                          var data = await Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child:  LocationSearch()));
                          if(!mounted || data ==  null) return;
                          setState(() {
                            senderLocation.text = data['address'];
                            senderLat = data['lat'];
                            senderLng = data['lng'];
                          });
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            fillColor: Colors.black12,
                            filled: true,
                            hintText: "Sender Location",
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
                            return 'Please enter sender location';
                          }


                          return null;
                        },
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                // top: 40,left: 80,
                top: 10,
                left: 20,

                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                  ),
                  child: Center(
                      child: Text(
                        "Sender Details",
                        style: TextStyle(fontSize: 15,fontFamily: "Lato_Bold",color: Colors.blueGrey),
                      )),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top:20),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.blueGrey,
                        width: 1,
                      )
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextFormField(
                          controller: recipientName,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              fillColor: Colors.black12,
                              filled: true,
                              hintText: "Recipient Name",
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
                              return 'Please recipient your sender name';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15,right:15,bottom:15),
                        child: TextFormField(
                          controller: recipientNumber,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              fillColor: Colors.black12,
                              filled: true,
                              hintText: "Sender Recipient Number",
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
                              return 'Please enter recipient phone number';
                            }

                            if(!isNumeric(value)){
                              return "Please enter a valid phone number";
                            }

                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15,right:15,bottom:15),
                        child: TextFormField(
                          controller: recipientLocation,
                          readOnly: true,
                          onTap: ()async{
                            var data = await Navigator.push(context, PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child:  LocationSearch()));
                            if(!mounted || data ==  null) return;
                            setState(() {
                              recipientLocation.text = data['address'];
                              recipientLat = data['lat'];
                              recipientLng = data['lng'];
                            });
                          },
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              fillColor: Colors.black12,
                              filled: true,
                              hintText: "Sender Location",
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
                              return 'Please enter recipient location';
                            }


                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  // top: 40,left: 80,
                  top: 10,
                  left: 20,

                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                    ),
                    child: Center(
                        child: Text(
                          "Receiver Details",
                          style: TextStyle(fontSize: 15,fontFamily: "Lato_Bold",color: Colors.blueGrey),
                        )),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top:20),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.blueGrey,
                        width: 1,
                      )
                  ),
                  child: Column(
                    children: [

                      Padding(
                        padding: EdgeInsets.all(15),
                        child: TextFormField(
                          controller: items,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              fillColor: Colors.black12,
                              filled: true,
                              hintText: "items eg. books, dress, tops, etc",
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
                              return 'What are you sending?';
                            }

                            return null;
                          },
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          _showPicker(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left:15,right: 15,bottom: 15),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.black12,  // red as border color
                            ),
                          ),
                          child: _image != null ? Image.file(_image) : Center(
                            child:Column(
                              children: [
                                Icon(CupertinoIcons.photo, size: 40,color: Colors.black38,),
                                Text("Item Photo",style: TextStyle(fontFamily: "Lato_Regular"),)
                              ],
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  // top: 40,left: 80,
                  top: 10,
                  left: 20,

                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                    ),
                    child: Center(
                        child: Text(
                          "Item Details",
                          style: TextStyle(fontSize: 15,fontFamily: "Lato_Bold",color: Colors.blueGrey),
                        )),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: FlatButton(onPressed: (){
              placeOrder();
            },
                child: Text("Place Order",style: TextStyle(color: Colors.white,fontFamily: "Lato_Bold"),),color: Colors.blue,minWidth: double.infinity,height: 50,shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.blue)
                )),
          ),
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
