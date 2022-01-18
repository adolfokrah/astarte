import 'dart:convert';
import 'dart:io';

import 'package:astarte/pages/signupPages/selectServices.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';
import '../config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main(){
  runApp(UpdateShopDetails());
}

class UpdateShopDetails extends StatefulWidget {
  final userDetails;

  UpdateShopDetails({Key key, @required this.userDetails}) : super(key: key);
  @override
  _UpdateShopDetailsState createState() => _UpdateShopDetailsState();
}

class _UpdateShopDetailsState extends State<UpdateShopDetails> {
  Config appConfiguration = new Config();
  final _formKey = GlobalKey<FormState>();
  TextEditingController brandName = TextEditingController();
  TextEditingController aboutShop = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController services = TextEditingController();
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: dotenv.env['MAPS_API_KEY']);

  var shopLat=0.0;
  var shopLng = 0.0;
  var selectedServicesState = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    brandName.text = widget.userDetails['brand_name'];
    aboutShop.text = widget.userDetails['about'];
    address.text = widget.userDetails['address'];
    services.text = jsonDecode(widget.userDetails['services']).join(',');
    if(!mounted) return;
    setState(() {
      selectedServicesState = jsonDecode(widget.userDetails['services']);
    });
  }


  void processForm()async{

    try{
      if(_formKey.currentState.validate()){


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
                    new Text("Updating shop details..."),
                  ],
                ),
              ),
            );
          },
        );


        var data = {};
        data['address'] = address.text;
        data['user_id'] = widget.userDetails['user_id'].toString();
        data['brand_name'] = brandName.text;
        data['about'] = aboutShop.text;
        data['photoPath'] = '';
        data['lat'] = shopLat == 0 ? widget.userDetails['lat'] : shopLat.toString();
        data['lng'] = shopLng == 0 ? widget.userDetails['lng'] : shopLng.toString();
        data['services'] = jsonEncode(selectedServicesState);
        data['password'] = widget.userDetails['password'];
        data['email'] = widget.userDetails['email'];


        var url = appConfiguration.apiBaseUrl + 'updateUserProfile.php';
        var response = await http.post(Uri.parse(url), body:data);

        Navigator.of(context,rootNavigator: true).pop();

        Fluttertoast.showToast(
            msg: "Shop details updated.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
        SharedPreferences storage = await SharedPreferences.getInstance();
        storage.setString("userDetails", response.body);
      }
    }catch(e){
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
      Navigator.of(context,rootNavigator: true).pop();

    }
  }

  void _getServices()async{
    var selectedServices = await  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SelectServices(selectedServices: selectedServicesState)));

    if(selectedServices != null){
      setState(() {
        services.text = selectedServices.join(",");
        selectedServicesState = selectedServices;
      });
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
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    var position =  await Geolocator.getCurrentPosition();
    List<Placemark> newPlace = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placeMark  = newPlace[0];
    String name = placeMark.name;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;
    var first = "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

    setState(() {
      shopLat = position.latitude;
      shopLng = position.longitude;
      address.text = first;
    });
    // searchFashionDesinger(position.latitude,position.longitude,start);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        title: "Update Shop Details",
        home:Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: false,
            title: Text("Update Shop Details",style: TextStyle(color: Colors.black,fontFamily: "Lato_Bold"),),
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
          body: UpdateShopDetailsContent(),
        )
    );
  }

  Widget UpdateShopDetailsContent(){
    return Container(
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                validator: (value){
                  if(value.isEmpty){
                    return "Please enter your shop/brand name";
                  }
                  return null;
                },
                controller: brandName,
                decoration: InputDecoration(
                    labelText: "Shop/Brand Name"
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 0, right: 20),
              child: TextFormField(
                maxLines: 8,
                validator: (value){
                  if (value.isEmpty) {
                    return 'Please tell us something about your shop';
                  }
                  return null;
                },
                controller: aboutShop,
                decoration: InputDecoration(
                    labelText: "About Shop"
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20, right: 20),
              child: TextFormField(
                controller: address,
                readOnly: true,
                onTap: (){
                  _handlePressButton();
                },
                decoration: InputDecoration(
                  hintText: "Shop Location",
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your shop location';
                  }

                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: FlatButton(
                onPressed: (){
                  determinPosition();
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(CupertinoIcons.location_fill,size:16),
                    ),
                    Text("My Location", style: TextStyle(fontSize: 16, fontFamily: "Lato_Regular"),)
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20, right: 20),
              child: TextFormField(
                controller: services,
                readOnly: true,
                onTap: (){
                  _getServices();
                },
                decoration: InputDecoration(
                  hintText: "Services",
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please select your services';
                  }

                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: appConfiguration.googleMapsApiKey,
        mode: Mode.overlay, // Mode.fullscreen
        language: "en",
         types: ["address"],
        strictbounds:false,
        components: [new Component(Component.country, "gh")]);
    displayPrediction(p);

  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      setState(() {
        shopLat = lat;
        shopLng = lng;
        address.text = p.description;
      });
    }
  }

}

