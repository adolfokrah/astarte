import 'dart:convert';

import 'package:astarte/pages/fashionDesignerProfile.dart';
import 'package:astarte/pages/login.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config.dart';

void main(){
  runApp(SearchPage());
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController _userSearchQuery = TextEditingController();
  TextEditingController _userSearchLocation = TextEditingController();
  Config appConfiguration = new Config();
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: dotenv.env['MAPS_API_KEY']);
  ScrollController controller;
  var searchLat;
  var searchLng;
  var start = 0;
  var searching = false;
  var fashionDesigners = [];
  var searched = false;
  var _locationName = '';
  var failed = false;
  var suggestedFashionDesigners = [];
  var userId  = "0";
  var styles = [];



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

    // var first = addresses.first;
    if(mounted){
      setState(() {
        searchLat = position.latitude;
        searchLng = position.longitude;
        _locationName = first;
      });
      searchFashionDesinger(position.latitude,position.longitude,start);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userSearchQuery.addListener(() {
      setState(() {});
    });

    _userSearchLocation.addListener(() {
      setState(() {});
    });

    getUserDetails();
    determinPosition();
    controller = new ScrollController()..addListener(_scrollListener);
  }


  getUserDetails() async {
    try {

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
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener(){
    if (controller.position.extentAfter < 500) {
      searchFashionDesinger(searchLat,searchLng,start);
    }
  }

  Future searchFashionDesinger(lat,lng,mstart)async{
    try{
      if(!mounted) return;
      if(mstart < 1) {
        setState(() {
          searching = true;
        });
      }

      var body = {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'start': start.toString(),
        'searchQuery': _userSearchQuery.text,
        'user_id':userId
      };


      var url = appConfiguration.apiBaseUrl + 'searchFashionDesigner.php';
      var response = await http.post(Uri.parse(url), body: body);


      var data = jsonDecode(response.body);


      var newfashionDesigners  = fashionDesigners;

      var newData = [];


      if(mstart > 0){
        newData = []..addAll(newfashionDesigners)..addAll(data['fashionDesigners']);
      }else{
        newData = data['fashionDesigners'];
      }

      if(!mounted) return;
      setState(() {
        searching = false;
        fashionDesigners = newData;
        searched = true;
        failed = false;
        suggestedFashionDesigners = data['suggestedFashionDesigners'];
        styles = data['styles'];
      });

      if(data.length > 0){
        if(!mounted) return;
        setState(() {
          start = start + 10;
        });
      }

      return true;
    }catch(e){
      print(e);
      if(!mounted) return;
      setState(() {
        searched = false;
        searching = false;
      });

      if(fashionDesigners.length < 1){
        setState(() {
          failed = true;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AppBar(
          toolbarHeight: 80,
          title: Container(
            height: 50,
            child: Column(
              children: [
                Center(
                  child: TextField(
                    onSubmitted: (e){
                      if(!mounted) return;
                      setState(() {
                        start = 0;
                      });
                      if(e.isEmpty){

                        setState(() {
                          fashionDesigners = [];
                          searched = true;
                        });
                      }
                      searchFashionDesinger(searchLat,searchLng,0);
                    },onChanged: (e){
                    if(!mounted) return;
                    setState(() {
                      start = 0;
                    });
                    if(e.isEmpty){

                      setState(() {
                        fashionDesigners = [];
                        searched = true;
                      });
                    }
                    searchFashionDesinger(searchLat,searchLng,0);
                  },
                    controller: _userSearchQuery,
                    style: TextStyle(color: Colors.black, fontFamily: "Lato_Regular",fontSize: 15.0),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 0, left: 10),
                        prefixIcon: IconButton(icon: Icon(Icons.my_location_outlined,color: Colors.black45),onPressed: (){
                          setState(() {
                            searched = false;
                            searching = true;
                          });
                          determinPosition();
                        },),
                        suffixIcon: _userSearchQuery.text.length > 0 ? IconButton(icon: Icon(CupertinoIcons.clear, color: Colors.black,), onPressed: (){
                          _userSearchQuery.text = "";
                          setState(() {
                            searching = false;
                            fashionDesigners = [];
                            searched = false;
                            start = 0;
                          });

                        }): null,
                        fillColor: Colors.black12,
                        filled: true,
                        hintText: "Search by style or designer name.",
                        hintStyle: TextStyle(fontFamily: "Lato_Regular",fontSize: 15.0),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12, width: 0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12, width: 0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            )
                        )
                    ),
                  ),
                )
              ],
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          brightness: Brightness.light,
          actions: [
            IconButton(
              onPressed: () async{
                _handlePressButton();
              },
              icon: Icon(CupertinoIcons.location, color: Colors.black),
            )
          ],
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
             color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black12)
        )
    ),
          child: ListView.builder(
            padding: EdgeInsets.only(top: 0),
            itemCount: styles.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context,index){
              return InkWell(
                onTap: (){
                  _userSearchQuery.text = styles[index];
                  if(!mounted) return;
                  setState(() {
                    start = 0;
                  });
                  searchFashionDesinger(searchLat,searchLng,0);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Chip(backgroundColor:Colors.white,label: Text(styles[index], style: TextStyle(fontFamily: "Lato_Regular"),),shape: StadiumBorder(side: BorderSide(color: Colors.black12)),),
                ),
              );
            },
          ),
        ),
        fashionDesigners.length  > 0 && !searching ? Padding(
            padding: EdgeInsets.all(20),
            child: Text(_userSearchQuery.text.length < 1 ? "Fashion designers  in "+_locationName : "\""+_userSearchQuery.text+" in "+_locationName,style:TextStyle(fontFamily: "Lato_Bold",color: Colors.black,fontSize: 14))): Container(),
        content(),
        suggestedFashionDesigners.length > 0 && fashionDesigners.length < 1  && !searching ? Padding(padding: EdgeInsets.all(20),child: Text("Suggested Fashion Designers",style: TextStyle(fontFamily: "Lato_Black",fontSize: 16)),) : Container(),
        fashionDesigners.length < 1 && !searching ? displayFashionDesigners() : Container(),
        // displayFashionDesigners()
        // Text(suggestedFashionDesigners[0]['brand_name'])
      ],
    );
  }


  Widget content(){


    if (searching){
      var search = _userSearchQuery.text.length < 1 ? "\"Fashion designers\"" : "\""+_userSearchQuery.text+"\"";
      search = search+' in '+_locationName;
      return Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 20),
                child: SpinKitFadingCircle(
                  color: Colors.blue,
                  size: 20.0,
                ),
              ),
              Flexible(child: Text("Searching for ${search}",style:TextStyle(fontFamily: "Lato_Bold",color: Colors.black54)))
            ],
          )
      );
    }

    if(failed && !searching){
      return Padding(
          padding: EdgeInsets.all(20),
          child: Text("Failed, please make sure you are connected to the internet",style:TextStyle(fontFamily: "Lato_Bold",color: Colors.black54)));
    }

    if(searched && fashionDesigners.length < 1){
      var search = _userSearchQuery.text.length < 1 ? "Fashion designers" : "\""+_userSearchQuery.text+"\"";
      search = search+' in '+_locationName;
      return Padding(
          padding: EdgeInsets.all(20),
          child: Text("No results found for ${search}",style:TextStyle(fontFamily: "Lato_Bold",color: Colors.black54)));
    }

    if(fashionDesigners.length > 0){
      return displayFashionDesigners();
    }else{
      return Container();
    }
  }

  Widget displayFashionDesigners(){

    var data = fashionDesigners.length < 1 ?  suggestedFashionDesigners : fashionDesigners;
    return Expanded(
      child: Container(
        child: ListView.separated(
          controller: controller,
          padding: EdgeInsets.only(top: 0),
          separatorBuilder: (context,index){
            return Divider();
          },
          itemCount: fashionDesigners.length < 1 ?  suggestedFashionDesigners.length : fashionDesigners.length,
          itemBuilder: (context,index){
            return InkWell(
              onTap: (){
                if(userId == '0'){
                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
                  return;
                }
                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: FashionDesignerProfile(userId: data[index]['user_id'],)));
              },
              child: ListTile(
                leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: CachedNetworkImageProvider(
                        appConfiguration.apiBaseUrl+''+data[index]['photo'])),
                title: Row(
                  children: [
                    Text(data[index]['brand_name'],style: TextStyle(fontFamily: "Lato_Bold")),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: data[index]['premium_account'] == 'true'? Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.blue,size:15) : null,
                    )
                  ],
                ),
                subtitle: Text(data[index]['about'],maxLines: 1,style: TextStyle(fontFamily: "Lato_Bold"),),
                trailing: Text(data[index]['distance'].toString()+' '+data[index]['units'],style: TextStyle(fontFamily: "Lato_Regular",fontSize: 13)),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: appConfiguration.googleMapsApiKey,
        mode: Mode.overlay,
        language: "en",
        strictbounds:false,
        types: ["address"],
        components: [new Component(Component.country, "gh")]);
    displayPrediction(p);
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      print(jsonEncode(p));
      // get detail (lat/lng)
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      setState(() {
        searchLat = lat;
        searchLng = lng;
        searching = true;
        searched = false;
        _locationName = p.description;
      });

      searchFashionDesinger(lat,lng,0);
    }
  }

}
