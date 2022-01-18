import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../config.dart';

class LocationSearch extends StatefulWidget {
  const LocationSearch({Key key}) : super(key: key);

  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: dotenv.env['MAPS_API_KEY']);
  Config appConfiguration = new Config();
  var lat,lng,address;
  var loading = true;
  var pointerUp = true;
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition kGooglePlex;
  GoogleMapController googleMapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    determinPosition();
  }


  Future determinPosition() async {
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
    // final coordinates = new Coordinates(position.latitude, position.longitude);
    List<Placemark> newPlace = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placeMark  = newPlace[0];
    String name = placeMark.name;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;
    var first = "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

    if(mounted){
      setState(() {
        lat = position.latitude;
        lng = position.longitude;
        address = first;
        loading = false;
      });
      kGooglePlex = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
        zoom: 16,
      );
    }
  }

  Future<void> _handlePressButton() async {
        Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: appConfiguration.googleMapsApiKey,
        mode: Mode.fullscreen, // Mode.fullscreen
        language: "en",
         types: ["address"],
            strictbounds:false,
        components: [new Component(Component.country, "gh")]);

        displayPrediction(p);
  }

  Future<Null> displayPrediction(Prediction p) async {

    if (p != null) {
      // get detail (lat/lng)
      if(!mounted) return;
      setState(() {
        loading = true;
      });
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
          p.placeId);
      final latp = detail.result.geometry.location.lat;
      final lngp = detail.result.geometry.location.lng;
      if (mounted) {
        setState(() {
          lat = latp;
          lng = lngp;
          address = p.description;
          loading = false;
        });
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(latp, lngp),
            zoom: 17.0)));
      }
    }
  }

  Future<void> getCenter() async {
    if(!mounted) return;
    setState(() {
      loading = true;
    });
    LatLngBounds visibleRegion = await googleMapController.getVisibleRegion();
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );

    // final coordinates = new Coordinates(centerLatLng.latitude, centerLatLng.longitude);
    // var addresses = await Geocoder.google(appConfiguration.googleMapsApiKey).findAddressesFromCoordinates(coordinates);
    //
    // var first = addresses.first;

    List<Placemark> newPlace = await placemarkFromCoordinates(centerLatLng.latitude, centerLatLng.longitude);
    Placemark placeMark  = newPlace[0];
    String name = placeMark.name;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;
    var first = "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

    if(mounted) {
      setState(() {
        loading = false;
        lat = centerLatLng.latitude;
        lng = centerLatLng.longitude;
        address = first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.close),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text("Choose Location",
            style: TextStyle(fontFamily: "Lato_Black", color: Colors.black)),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0.5,
          brightness: Brightness.light
      ),
      body: lat !=null ? Stack(
        children: [
          Listener(
            onPointerUp: (e) async{
                setState(() {
                   pointerUp = true;
                });
            },
            onPointerDown: (e){
              setState(() {
                pointerUp = false;
              });
            },
            child: GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: false,
                  zoomControlsEnabled: true,
                 onCameraMove: (p){
                   if(pointerUp){
                     getCenter();
                     setState(() {
                       pointerUp = false;
                     });
                   }
                 },
                 initialCameraPosition: kGooglePlex,
                 onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  googleMapController = controller;
                 }
            ),
          ),
          Positioned(
            top: 0,
            left:0,
            child: InkWell(
              onTap: _handlePressButton,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white
                  ),
                  child: ListTile(
                    leading: loading ? CupertinoActivityIndicator() : null,
                    title: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(fontFamily: "Lato_Regular",fontSize: 18),),
                  )
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: 10,
            child: FloatingActionButton(
              elevation: 2,
              onPressed: (){
                var data = {
                  "lat": lat,
                  "lng": lng,
                  "address":address
                };
                Navigator.pop(context,data);
              },
              child: Icon(Icons.arrow_forward,color: Colors.white,),
            ),
          ),
          Positioned.fill(
            child: Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Image.asset("assets/images/marker.png",scale: 17,)),
            ),
          )
        ],
      ) : Center(child: CupertinoActivityIndicator(),),
    );
  }
}
