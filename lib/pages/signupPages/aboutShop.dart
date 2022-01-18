import 'dart:convert';

import 'package:astarte/pages/signupPages/selectServices.dart';
import 'package:astarte/pages/signupPages/uploadPhoto.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:string_validator/string_validator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../config.dart';
import '../login.dart';

void main(){
  runApp(AboutShop());
}

class AboutShop extends StatefulWidget {
  final userInfo;

  AboutShop({Key key, @required this.userInfo}) : super(key: key);
  @override
  _AboutShopState createState() => _AboutShopState();
}

class _AboutShopState extends State<AboutShop> {
  Config appConfiguration = new Config();
  final _formKey = GlobalKey<FormState>();
  TextEditingController shopName = TextEditingController();
  TextEditingController aboutShop = TextEditingController();
  TextEditingController address  = TextEditingController();
  TextEditingController services = TextEditingController();

  var shopLat = 0.0;
  var shopLng = 0.0;
  var loading = false;
  var selectedServicesState = [];

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: dotenv.env['MAPS_API_KEY']);




  void processForm(){
    if(_formKey.currentState.validate()) {
      var customerData = {
        'address':address.text,
        'lat': shopLat.toString(),
        'lng': shopLng.toString(),
        'about': aboutShop.text,
        'brand_name': shopName.text,
        'services': jsonEncode(selectedServicesState)
      };

      var data = widget.userInfo;
      data.addAll(customerData);

      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UploadPhoto(userInfo:data)));

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

    if(mounted){
      setState(() {
        loading = true;
      });
    }

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
    // final coordinates = new Coordinates(position.latitude, position.longitude);
    // var addresses = await Geocode.google(appConfiguration.googleMapsApiKey).findAddressesFromCoordinates(coordinates);
    //
    // var first = addresses.first;

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
      loading = false;
    });
    // searchFashionDesinger(position.latitude,position.longitude,start);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: appConfiguration.appColor),
      title: "Fashion Designer SignUp",
      home: LoadingOverlay(
        isLoading : loading,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            brightness: Brightness.light,
            leading: IconButton(icon: Icon(CupertinoIcons.back, color: Colors.black),onPressed: (){
              Navigator.pop(context);
            },),
          ),
          body: signUpContainer(),
        ),
      ),
    );
  }

  Widget signUpContainer(){
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20.0),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text("Let's know more about you",style: TextStyle(fontFamily: "Lato_Black",fontSize: 30),),
                        Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("Customers would like to reach you any where you are, tell them about your self.",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 15),textAlign: TextAlign.center,))
                      ],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20,bottom:20),
                          child: TextFormField(
                            controller: shopName,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                fillColor: Colors.black12,
                                filled: true,
                                hintText: "Shop / Brand Name",
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
                                return 'Please enter your shop/brand name';
                              }

                              // if(!isAlpha(value)){
                              //   return "Please do not include special characters";
                              // }

                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20,bottom:20),
                          child: TextFormField(
                            controller: aboutShop,
                            maxLines: 8,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                fillColor: Colors.black12,
                                filled: true,
                                hintText: "About Shop",
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
                                return 'Please enter your shop name';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10,bottom:20),
                          child: TextFormField(
                            controller:address,
                            readOnly: true,
                            onTap: (){
                              _handlePressButton();
                            },
                            decoration: InputDecoration(
                                fillColor: Colors.black12,
                                filled: true,
                                hintText: "Shop Location",
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
                                ),
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
                          padding: const EdgeInsets.only(top: 0.0, bottom: 10),
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
                          padding: EdgeInsets.only(top: 10,bottom:20),
                          child: TextFormField(
                            controller:services,
                            readOnly: true,
                            onTap: (){
                              _getServices();
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.black12,
                              filled: true,
                              hintText: "Services",
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
                              ),
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
                        FlatButton(onPressed: (){
                          processForm();
                        },
                            child: Text("Continue",style: TextStyle(color: Colors.white,fontFamily: "Lato_Bold"),),color: Colors.blue,minWidth: double.infinity,height: 50,shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.blue)
                            )),

                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 70,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12, width: 1)),
            color: Colors.white,
          ),
          child: InkWell(
            onTap: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            child: Center(
              child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text:"Already have an account?",
                        style: TextStyle(
                            fontFamily: "Lato_Bold",
                            color: Colors.black87,
                            fontSize: 14)),
                    TextSpan(
                        text: "  Login",
                        style: TextStyle(
                            fontFamily: "Lato_Black",
                            color: Color(0xff0468c5),
                            fontSize: 14))
                  ])),
            ),
          ),
        )
      ],
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
    try{
      if (p != null) {
        // get detail (lat/lng)
        if(mounted){
          setState(() {
            loading = true;
          });
        }
        PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
        final lat = detail.result.geometry.location.lat;
        final lng = detail.result.geometry.location.lng;

        if(!mounted) return;
        setState(() {
          shopLat = lat;
          shopLng = lng;
          address.text = p.description;
          loading = false;
        });
      }
    }catch(e){
      if(!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }
}
