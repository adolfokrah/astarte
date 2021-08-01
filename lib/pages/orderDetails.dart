import 'dart:convert';

import 'package:astarte/config.dart';
import 'package:astarte/widgets/connection_failed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:http/http.dart' as http;

class OrderDetails extends StatefulWidget {
  final orderId;
  const OrderDetails({Key key, this.orderId}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {

  var order = {};
  var fetchingOrder = true;
  var userId = "0";
  var failedFetchingOrder = false;
  Config appConfiguration = Config();

  @override
  void initState(){
    getOder(widget.orderId);
  }

  getOder(orderId)async{
    try{
      if(mounted)
        setState(() {
          fetchingOrder = true;
        });
      var data ={
        "order_id": orderId,
      };
      var url = appConfiguration.apiBaseUrl + 'fetch_order.php';
      var response = await http.post(url, body: data);

      if(mounted){
       setState(() {
         order = jsonDecode(response.body);
         failedFetchingOrder = false;
       });
      }
    }catch(e){
      print(e);
      if(mounted)
        setState(() {
          failedFetchingOrder = true;
        });
    }finally{
     if(mounted)
       setState(() {
         fetchingOrder = false;
       });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back,color: Colors.black,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text("#"+widget.orderId.padLeft(8,"0"),
            style: TextStyle(fontFamily: "Lato_Black", color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        brightness: Brightness.light,

      ),
      body: content(),
    );
  }
  Widget content(){
      if(fetchingOrder == true){
        return Center(
          child: SpinKitWave(
            color: Colors.blue,
            size: 20.0,
          ),
        );
      }
      if(failedFetchingOrder == true){
        return ConnectionFailed(callback:(){getOder(widget.orderId);});
      }
      return ListView(
        children: [
          InkWell(
            onTap: (){
              print(order['item_photo']);
              if(order['item_photo'] == "" ) return;
              ImageViewer.showImageSlider(
                images: ["${appConfiguration.apiBaseUrl}${order['item_photo']}"],
                startingPosition: 1,
              );
            },
            child: Container(
              height: 200,
              child:order['item_photo'] == "" ? Icon(CupertinoIcons.photo, size: 55,color: Colors.black45,) : null,
              decoration:  BoxDecoration(
                  color: Colors.black12,
                  image: order['item_photo'] != "" ? DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider("${appConfiguration.apiBaseUrl}${order['item_photo']}")
                  ): null
              ),
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue,
                                child: Icon(CupertinoIcons.cube_box_fill, color: Colors.white,size: 15,),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Order ID",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 14),),
                              )
                            ],
                          ),
                          Text("#"+widget.orderId.padLeft(8,"0"),style: TextStyle(fontFamily: "Lato_Bold"),),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat("dd, MMM yyyy - h:m a").format(DateTime.parse(order['date_time_placed'])).toString(),style: TextStyle(fontSize: 12),),
                          Container(
                            margin: EdgeInsets.only(top:3),
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: order['status'] == 'pending' ? Colors.orange : order['status'] == 'completed' ? Colors.blue : order['status'] == 'active' ? Colors.green : Colors.red,
                            ),
                            child: Text("${order['status']}",style: TextStyle(color: Colors.white,fontSize: 12),),
                          )
                        ],
                      )
                    ],
                  ),
                  Divider(),
                  Text("Items",style: TextStyle(fontFamily: "Lato_Regular",fontSize: 14)),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.cube_box),
                        Flexible(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(order['items'],style: TextStyle(fontFamily: "Lato_Regular"),),
                        ))
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      TimelineTile(
                        alignment: TimelineAlign.start,
                        isFirst: true,
                        afterLineStyle: const LineStyle(
                          color: Colors.black26,
                          thickness: 2,
                        ),
                        indicatorStyle: IndicatorStyle(
                            color: Colors.blue,
                            width: 15
                        ),
                        endChild: Padding(
                          padding: EdgeInsets.fromLTRB(10,10,10,10),
                          child: Text(order['pickup_location'],),
                        ),
                      ),
                      TimelineTile(
                        alignment: TimelineAlign.start,
                        isLast: true,
                        beforeLineStyle: const LineStyle(
                          color: Colors.black26,
                          thickness: 2,
                        ),
                        indicatorStyle: IndicatorStyle(
                            color: Colors.green,
                            width: 15
                        ),
                        endChild: Padding(
                          padding: EdgeInsets.fromLTRB(10,10,10,10),
                          child:  Text(order['dropoff_address']),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Sender"),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Icon(CupertinoIcons.person_fill, color: Colors.white,),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(order['sender_name'],style: TextStyle(fontFamily: "Lato_Bold",fontSize: 17),),
                                      Text(order['sender_number'],style: TextStyle(fontFamily: "Lato_Regular",fontSize: 13),)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Recipient"),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(CupertinoIcons.person_fill, color: Colors.white,),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(order['recipient_name'],style: TextStyle(fontFamily: "Lato_Bold",fontSize: 17),),
                                      Text(order['recipient_number'],style: TextStyle(fontFamily: "Lato_Regular",fontSize: 13),)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tracking",style: TextStyle(fontFamily: "Lato_Bold",fontSize: 15),),
                  Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TimelineTile(
                        alignment: TimelineAlign.start,
                        isFirst: true,
                        afterLineStyle: const LineStyle(
                          color: Color(0xff66C880),
                          thickness: 3,
                        ),
                        indicatorStyle: IndicatorStyle(
                            color: Color(0xff66C880),
                            width: 20
                        ),
                        endChild: Padding(
                          padding: EdgeInsets.fromLTRB(10,10,10,10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Order Placed",style: TextStyle(fontFamily: "Lato_Bold",fontSize: 15),),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text("Order placed on "+DateFormat("h:m a").format(DateTime.parse(order['date_time_placed'])).toString(),style: TextStyle(fontSize: 12),),
                              )
                            ],
                          ),
                        ),
                      ),
                      TimelineTile(
                        alignment: TimelineAlign.start,
                        isFirst: false,
                        afterLineStyle:  LineStyle(
                          color: order['assigned_time'] != "0000-00-00 00:00:00" ? Color(0xff66C880) : Color(0xffa1a49f),
                          thickness: 3,
                        ),
                        beforeLineStyle: const LineStyle(
                          color: Color(0xff66C880),
                          thickness: 3,
                        ),
                        indicatorStyle: IndicatorStyle(
                            color: order['assigned_time'] != "0000-00-00 00:00:00" ? Color(0xff66C880) : Color(0xffa1a49f),
                            width: 20
                        ),
                        endChild: Padding(
                          padding: EdgeInsets.fromLTRB(10,10,10,10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Order Assigned",style: TextStyle(fontFamily: "Lato_Bold",fontSize: 15),),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: order['assigned_time'] == "0000-00-00 00:00:00" ? Text("Order not assigned to a rider") : Text("Order assigned to  ${order['rider']['rider_name']} on "+DateFormat("h:m a").format(DateTime.parse(order['date_time_placed'])).toString(),style: TextStyle(fontSize: 12),),
                              )
                            ],
                          ),
                        ),
                      ),
                      TimelineTile(
                        alignment: TimelineAlign.start,
                        isFirst: false,
                        afterLineStyle:  LineStyle(
                          color: order['picked_up_time'] != "0000-00-00 00:00:00" ? Color(0xff66C880) : Color(0xffa1a49f),
                          thickness: 3,
                        ),
                        beforeLineStyle:  LineStyle(
                          color: order['assigned_time'] != "0000-00-00 00:00:00" ? Color(0xff66C880) : Color(0xffa1a49f),
                          thickness: 3,
                        ),
                        indicatorStyle: IndicatorStyle(
                            color: order['picked_up_time'] != "0000-00-00 00:00:00" ? Color(0xff66C880) : Color(0xffa1a49f),
                            width: 20
                        ),
                        endChild: Padding(
                          padding: EdgeInsets.fromLTRB(10,10,10,10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Items Picked",style: TextStyle(fontFamily: "Lato_Bold",fontSize: 15),),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: order['picked_up_time'] == "0000-00-00 00:00:00" ? null : Text("Items picked  on "+DateFormat("h:m a").format(DateTime.parse(order['picked_up_time'])).toString(),style: TextStyle(fontSize: 12),),
                              )
                            ],
                          ),
                        ),
                      ),
                      TimelineTile(
                        alignment: TimelineAlign.start,
                        isLast: true,
                        afterLineStyle:  LineStyle(
                          color: order['date_time_completed'] != "0000-00-00 00:00:00" ? Color(0xff66C880) : Color(0xffa1a49f),
                          thickness: 3,
                        ),
                        beforeLineStyle:  LineStyle(
                          color: order['assigned_time'] != "0000-00-00 00:00:00" ? Color(0xff66C880) : Color(0xffa1a49f),
                          thickness: 3,
                        ),
                        indicatorStyle: IndicatorStyle(
                            color: order['date_time_completed'] != "0000-00-00 00:00:00" ? Color(0xff66C880) : Color(0xffa1a49f),
                            width: 20
                        ),
                        endChild: Padding(
                          padding: EdgeInsets.fromLTRB(10,10,10,10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Items Delivered",style: TextStyle(fontFamily: "Lato_Bold",fontSize: 15),),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: order['date_time_completed'] == "0000-00-00 00:00:00" ? null : Text("Items delivered  on "+DateFormat("h:m a").format(DateTime.parse(order['date_time_completed'])).toString(),style: TextStyle(fontSize: 12),),
                              )
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      if(order['assigned_time'] != "0000-00-00 00:00:00")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RawMaterialButton(
                              onPressed: ()async{
                                var number = order['rider']['rider_number']; //set the number here
                                await FlutterPhoneDirectCaller.callNumber(number);
                              },
                              elevation: 0,
                              fillColor: Color(0xff66C880),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 20.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Call", style: TextStyle(fontFamily: "Lato_Bold",color: Colors.white),),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.all(5.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child:  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(order['rider']['rider_name'],textAlign: TextAlign.right,),
                                  ),
                                ),
                                CircleAvatar(
                                    radius: 16,
                                    backgroundImage: CachedNetworkImageProvider(
                                        appConfiguration.apiBaseUrl+''+order['rider']['rider_photo']))
                              ],
                            )
                          ],
                        )

                    ],
                  )
                ],
              ),
            ),
          ),
          if(double.parse(order['delivery_cost']) > 0)
            Card(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Delivery cost",style:TextStyle(fontFamily: "Lato_Regular")),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Text("¢ "+double.parse(order['delivery_cost']).toStringAsFixed(2).toString(),style: TextStyle(fontFamily: "Lato_Black",fontSize: 25),),
                    )
                  ],
                ),
              ),
            )
        ],
      );

  }
}
