import 'dart:async';
import 'dart:convert';

import 'package:astarte/pages/myReviews.dart';
import 'package:astarte/pages/sendReview.dart';
import 'package:astarte/pages/viewImage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import 'login.dart';

void main(){
  runApp(FashionDesignerProfile());
}
class FashionDesignerProfile extends StatefulWidget {
  var userId;
  FashionDesignerProfile({Key key, @required this.userId}) : super(key: key);
  @override
  _FashionDesignerProfileState createState() => _FashionDesignerProfileState();
}

class _FashionDesignerProfileState extends State<FashionDesignerProfile>  with SingleTickerProviderStateMixin{

  Config appConfiguration = new Config();
  TabController controller;
  ScrollController _scrollController = new ScrollController();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition kGooglePlex;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  var loading = true;
  var userDetails;
  var failed = false;
  var top = false;
  var userId = '0';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

   controller =  new TabController(length: 3, vsync: this);
    getUserDetails();
    _scrollController.addListener(() {
      if(_scrollController.offset > 250){
        setState(() {
          top = true;
        });
      }else{
        setState(() {
          top = false;
        });
      }
    });
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
        getFashionDesingerDetails();

        return;
      }else{
        getFashionDesingerDetails();
      }

    } catch (e) {
      print(e);
    }
  }

  Future getFashionDesingerDetails()async{
    try{

      var url = appConfiguration.apiBaseUrl + 'getFashionDesingerProfile.php';
      var data = {
        'user_id': widget.userId.toString()
      };

      var response = await http.post(Uri.parse(url), body: data);

      if(!mounted) return;
      setState(() {
        loading = false;
        userDetails = jsonDecode(response.body);
      });

      kGooglePlex = CameraPosition(
        target: LatLng(double.parse(userDetails['userInfo']['lat']), double.parse(userDetails['userInfo']['lng'])),
        zoom: 14.4746,
      );
      final MarkerId markerId = MarkerId("1");
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(double.parse(userDetails['userInfo']['lat']), double.parse(userDetails['userInfo']['lng'])),
      );

      setState(() {
        // adding a new marker to map
        markers[markerId] = marker;
      });
    }catch(e){
      setState(() {
        failed = true;
      });
    }
  }

  _callNumber() async{
    var number = userDetails['userInfo']['mobile_number']; //set the number here
    bool res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  void sharePost(){
    Share.share('Wow, check this fashion designer on astarte');
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: appConfiguration.appColor),
        title: "ForgotPassword",
        home: fashionDesignerProfileContent()

    );

  }

  Widget fashionDesignerProfileContent(){
    if(failed){
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(CupertinoIcons.back,color:Colors.black),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Icon(Icons.wifi, size: 200, color: Colors.black26),
              Text("Oops! connection failed",
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
                  Text("TRY AGAIN", style: TextStyle(fontFamily: "Lato_Bolf")))
            ],
          ),
        ),
      );
    }

    if(loading){
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
          icon: Icon(CupertinoIcons.back,color:Colors.black),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
        ),
        body: Container(
          color: Colors.white,
          child: Center(child: SpinKitWave(
            color: Colors.blue,
            size: 20.0,
          )),
        ),
      );
    }else{

       return Scaffold(
         body: Container(
           child: DefaultTabController(
            length: 3,
            child: Container(
                child: CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                  SliverAppBar(
                    brightness: top ? Brightness.light : Brightness.dark,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    pinned: true,
                    floating: false,
                    expandedHeight: 350,
                    centerTitle: false,
                    title: top ? Text(userDetails['userInfo']['brand_name'],style:TextStyle(fontFamily: "Lato_Bold",color: Colors.black,fontSize: 17) ,) : null,
                    leading: IconButton(
                      icon: Icon(CupertinoIcons.back,color: top ? Colors.black : Colors.white,),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(appConfiguration.apiBaseUrl+''+userDetails['userInfo']['photo']
                                ))
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 50,right: 20),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  height: 80,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Center(
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Text(double.parse((userDetails['reviews'].length / 20).toStringAsFixed(1)) >= 5.0 ? "5.0" : (userDetails['reviews'].length / 20).toStringAsFixed(1),style: TextStyle(fontFamily: "Lato_Black",color: Colors.white,fontSize: 30),),
                                          Text(userDetails['reviews'].length.toString()+" reviews",style: TextStyle(fontFamily: "Lato_Black",color: Colors.white,fontSize: 10),)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                userDetails['userInfo']['premium'] == 'true' ? Padding(
                                  padding: const EdgeInsets.only(left: 8,bottom: 20),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    width: 200,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5,left: 5),
                                          child: Icon(Icons.thumb_up_alt_sharp,color: Colors.black,size: 15,),
                                        ),
                                        Text("ASTARTE RECOMMENDED",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 13),)
                                      ],
                                    ),
                                  ),
                                ) : Container(),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  color: Colors.white,
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(userDetails['userInfo']['brand_name'],style:TextStyle(fontFamily: "Lato_Bold",fontSize: 20) ,),
                                            Text(userDetails['userInfo']['address'].replaceAll("\n", " "),softWrap: true,style:TextStyle(fontFamily: "Lato_Regular",fontSize: 14,color: Colors.black87) ,)
                                          ],),
                                      ),
                                      IconButton(
                                        icon: Icon(CupertinoIcons.phone),
                                        onPressed: (){
                                          _callNumber();
                                        },
                                      )
                                      ,
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: controller,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black87,
                            indicatorColor: Colors.black,
                            labelStyle: TextStyle(fontFamily: "Lato_Bold"),
                            tabs: [
                              Tab(text: "Portfolio"),
                              Tab(text: "Reviews"),
                              Tab(text: "Details")
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                  new SliverFillRemaining(
                   hasScrollBody: true,
                    child: TabBarView(
                      controller: controller,
                      children: <Widget>[
                        portfolio(),
                        reviews(),
                        details(),
                      ],
                    ),
                  ),
                ])),
      ),
         ),
       );

    }
  }

  Widget details(){
    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.only(top: 0,bottom: 10),
        shrinkWrap: true,
        physics: new NeverScrollableScrollPhysics(),
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 240,
                child: GoogleMap(
                  markers: Set<Marker>.of(markers.values),
                  mapType: MapType.normal,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  initialCameraPosition: kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
              Container(
                height: 220,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 20, right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          )
                        ]
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: CachedNetworkImageProvider(
                                appConfiguration.apiBaseUrl+''+userDetails['userInfo']['photo'])),
                        title: Text(userDetails['userInfo']['brand_name'],style: TextStyle(fontFamily: "Lato_Bold"),overflow: TextOverflow.ellipsis),
                        subtitle: Text(userDetails['userInfo']['address'],style: TextStyle(fontFamily: "Lato_Regular"),overflow: TextOverflow.ellipsis,),
                        trailing: Container(
                          padding: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide( //                   <--- left side
                                color: Colors.black,
                                width: 0.2,
                              ),
                            )
                          ),
                          child: IconButton(
                            icon: Icon(CupertinoIcons.location_fill),
                            onPressed: ()async{
                              String googleUrl = "https://www.google.com/maps/search/?api=1&query=${userDetails['userInfo']['lat']},${userDetails['userInfo']['lng']}";
                              if (await canLaunch(googleUrl)) {
                                await launch(googleUrl);
                              } else {
                                throw 'Could not launch $googleUrl';
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text("ABOUT", style: TextStyle(fontFamily: "Lato_Black"),),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 0),
            child: Text(userDetails['userInfo']['about'], style: TextStyle(fontFamily: "Lato_Regular",color: Colors.black45),),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text("SERVICES", style: TextStyle(fontFamily: "Lato_Black"),),
          ),
          services(),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text("CONTACT", style: TextStyle(fontFamily: "Lato_Black"),),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide( //                   <--- left side
                      color: Colors.black,
                      width: 0.4,
                    ),
                      bottom: BorderSide( //                   <--- left side
                        color: Colors.black,
                        width: 0.4,
                      )
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(CupertinoIcons.phone,color: Colors.black45,),
                    Text(userDetails['userInfo']['mobile_number'], style: TextStyle(fontFamily: "Lato_Bold"),),InkWell(
                      onTap: (){
                        _callNumber();
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Colors.black45),
                        ),
                        child: Text("CALL"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text("SOCIAL MEDIA & SHARE", style: TextStyle(fontFamily: "Lato_Black"),),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: socialMedai(),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: userId == userDetails['userInfo']['user_id'] ? Container() : RaisedButton(
              color: Colors.orange,
              onPressed: ()async{

                if(userId == '0'){
                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Login()));
                  return;
                }

               await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SendReviews(userId: widget.userId,)));
                getUserDetails();
              },
              child: Text("Rate this fashion designer", style: TextStyle(fontFamily: "Laot_Bold",color:Colors.white),),
            ),
          )
        ],
      ),
    );
  }

  Widget services(){

    if(userDetails['services'] == '') return Container();
    var services = jsonDecode(userDetails['userInfo']['services']);
    List <Widget> list = List<Widget>();
    for(var i=0; i<services.length; i++){
      list.add(
         Padding(
           padding: EdgeInsets.only(left: 5, right: 5),
           child: Chip(backgroundColor: Colors.white,label: Text(services[i],style: TextStyle(fontFamily: "Lato_Regular")),shape: StadiumBorder(side: BorderSide(color: Colors.black12))),
         )
      );
    }

    return Wrap(
      children: list
    );

  }
  Widget socialMedai(){
    List <Widget> list = List<Widget>();

    for(var i=0; i<userDetails['socialMediaLinks'].length; i++){
      var icon  = FontAwesomeIcons.whatsapp;
      if(userDetails['socialMediaLinks'][i]['link'] != ''){
        if(userDetails['socialMediaLinks'][i]['site_name'] == 'Twitter'){
          icon  = FontAwesomeIcons.twitter;
        }else if (userDetails['socialMediaLinks'][i]['site_name'] == 'Instagram'){
          icon  = FontAwesomeIcons.instagram;
        }else if (userDetails['socialMediaLinks'][i]['site_name'] == 'Facebook'){
          icon  = FontAwesomeIcons.facebook;
        }


      list.add(
          Column(
            children: [
              IconButton(
                onPressed: ()async{
                  String googleUrl = userDetails['socialMediaLinks'][i]['link'];

                  if (userDetails['socialMediaLinks'][i]['site_name'] == 'Whatsapp'){
                    googleUrl = "https://api.whatsapp.com/send/?phone=${userDetails['socialMediaLinks'][i]['link']}&text&app_absent=0";
                  }

                  if (await canLaunch(googleUrl)) {
                    await launch(googleUrl);
                  } else {
                  throw 'Could not launch $googleUrl';
                  }
                },
                icon: FaIcon(icon,color: Colors.black45,size: 30,),),
              Text(userDetails['socialMediaLinks'][i]['site_name'], style: TextStyle(fontFamily: "Lato_Regular",color: Colors.black45))
            ],
          )
      );
      }
    }

    list.add(
        Column(
          children: [
            IconButton(
              onPressed: (){
                sharePost();
              },
              icon: FaIcon(FontAwesomeIcons.share,color: Colors.black45,size: 30,),),
            Text("Share", style: TextStyle(fontFamily: "Lato_Regular",color: Colors.black45))
          ],
        )
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: list,
    );
  }
  Widget reviews(){
    if(userDetails['reviews'].length < 1){
      return Center(
        child: Column(
          children: [
            Icon(CupertinoIcons.bubble_left_bubble_right_fill, size: 100, color: Colors.black26),
            Text("No reviews",
                style: TextStyle(
                    fontFamily: "Lato_Regular",
                    fontSize: 15,
                    color: Colors.black45)),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: new NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 0),
        separatorBuilder: (context,index){
          return Divider();
        },
        itemCount: userDetails['reviews'].length,
        itemBuilder: (context,index){
          return ListTile(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                      radius: 15,
                      backgroundImage: CachedNetworkImageProvider(
                          appConfiguration.apiBaseUrl+''+userDetails['reviews'][index]['photo'])),
                ),
                Text(userDetails['reviews'][index]['full_name'],style: TextStyle(fontFamily: "Lato_Bold"),)
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: stars(int.parse(userDetails['reviews'][index]['rating'])),
                ),
                Padding(
                  padding: EdgeInsets.only(left:0),
                  child: Text(userDetails['reviews'][index]['message'],style: TextStyle(fontFamily: "Lato_Regular"),),
                ),
                InkWell(
                  onTap: (){
                    if(userDetails['reviews'][index]['attached_photo'] == ''){
                      return;
                    }
                    var data = {
                      'description': userDetails['reviews'][index]['message'],
                      'selectedImage' : 0
                    };
                    var ndata = jsonEncode([userDetails['reviews'][index]['attached_photo']]);
                    data['images'] = ndata;
                    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewImage(data: data)));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Container(
                      height: userDetails['reviews'][index]['attached_photo'] == '' ? 0 : 120,
                      width: 100,
                      child: userDetails['reviews'][index]['attached_photo'] == '' ? null : CachedNetworkImage(
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain),
                          ),
                        ),
                        imageUrl: appConfiguration.apiBaseUrl+''+userDetails['reviews'][index]['attached_photo'],
                        placeholder: (context, url) => SpinKitWave(
                          color: Colors.blue,
                          size: 20.0,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                )
              ],
            ),
            trailing: Text(userDetails['reviews'][index]['date'], style: TextStyle(fontFamily: "Lato_Regular")),
          );
        },
      ),
    );
  }
  Widget portfolio(){
    return Container(
      child: GridView(
        physics: new NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top:0,bottom: 0),
        shrinkWrap: true,
        // primary: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3),
        children: List.generate(userDetails['gallery'].length, (index) {
          return InkWell(
            onTap: (){
              var data = userDetails['gallery'][index];
              data['selectedImage'] = 0;
              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ViewImage(data: data)));
            },
            child: Container(
              margin: EdgeInsets.all(1),
              height: 100.0,
              width: 100.0,
              color: Colors.black12,
              child: Stack(
                children: [
                   Container(
                     child: CachedNetworkImage(
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover),
                          ),
                        ),
                         imageUrl: appConfiguration.apiBaseUrl+''+jsonDecode(userDetails['gallery'][index]['images'])[0],
                           errorWidget: (context, url, error) => Icon(Icons.error),
                         ),
                   ),
                  Align(
                    alignment: Alignment.topRight,
                    child:jsonDecode(userDetails['gallery'][index]['images']).length > 1 ? Padding(padding: EdgeInsets.all(5),child: Icon(CupertinoIcons.rectangle_fill_on_rectangle_fill,color: Colors.white,),) : Container(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
      color: Colors.white,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
