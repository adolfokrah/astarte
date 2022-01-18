import 'dart:convert';

import 'package:astarte/config.dart';
import 'package:astarte/pages/new_order.dart';
import 'package:astarte/pages/orderDetails.dart';
import 'package:astarte/widgets/connection_failed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:http/http.dart' as http;

class Delivery extends StatefulWidget {
  const Delivery({Key key}) : super(key: key);

  @override
  _DeliveryState createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Config appConfiguration = Config();
  var filters = ["All Orders","Pending Orders","Ongoing Orders","Cancelled Orders","Completed Orders"];
  var activeFilter = 'All Orders';
  var orders = [];
  var loading = true;
  var userId = "0";
  var fetchOrdersStart = 0;
  var failed = false;

  @override
  void initState(){

    getOrders(activeFilter);
  }

  getUserDetails() async {
    try {

      SharedPreferences storage = await SharedPreferences.getInstance();
      String userDetails = storage.getString('userDetails');
      if (userDetails != null) {
        var userDetailsArray = jsonDecode(userDetails);
        if(mounted)
          setState(() {
            userId = userDetailsArray['user_id'].toString();
          });
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  updateFilter(filter){
    if(mounted)
      setState(() {
        activeFilter = filter;
      });
  }

  getOrders(status)async{
    try{
      await getUserDetails();
      if(status != activeFilter){
        fetchOrdersStart = 0;
        orders = [];
      }

      if(orders.length < 1){
        loading = true;
      }
      activeFilter = status;
      var data ={
        "user_id": userId,
        "start":fetchOrdersStart.toString(),
        "records":"5",
        "status":status
      };
      var url = appConfiguration.apiBaseUrl + 'fetch_user_orders.php';
      var response = await http.post(Uri.parse(url), body: data);
      if(mounted)
        setState(() {
          failed = false;
        });
      if(jsonDecode(response.body).length > 0){
        if(mounted){
          setState(() {
            fetchOrdersStart += 5;
          });
        }
      }

      if(orders.length > 0){
        if(mounted)
          setState(() {
            orders = [...orders, ...jsonDecode(response.body)];
          });
      }else{
        if(mounted)
          orders = jsonDecode(response.body);
      }
    }catch(e){
      if(orders.length < 1 && mounted)
        setState(() {
          failed = true;
        });
    }finally{
      if(mounted)
        loading = false;
    }
  }


  Future<void> openNewOrder()async{
    var data = await Navigator.push(context, PageTransition(
        type: PageTransitionType.rightToLeft,
        child:  NewOrder()));

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text("Deliveries",
            style: TextStyle(fontFamily: "Lato_Black", color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        brightness: Brightness.light,
        actions: [
          IconButton(
            onPressed: (){
              showMaterialModalBottomSheet(
                  context: context,
                  expand: false,
                  builder: (context)=>Container(
                    child: ListView(
                      padding: EdgeInsets.only(top: 8),
                      children: [
                        Center(child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                        ),),
                        ListTile(
                          title: Text("Filter by",style: TextStyle(fontFamily: "Lato_Bold"),),
                        ),
                        for(var i=0; i<filters.length; i++)InkWell(
                          child: ListTile(
                            onTap:(){
                              getOrders(filters[i]);
                              Navigator.pop(context);
                            },
                            leading: activeFilter == filters[i] ? Icon(Icons.check) : null,
                            title: Text(filters[i], style: TextStyle(fontFamily: "Lato_Regular")),
                          ),
                        )
                      ],
                    ),
                    height: 380,
                  )
              );
            },
            icon: Icon(CupertinoIcons.square_favorites, color: Colors.black),
          ),
          IconButton(
            onPressed: (){
              openNewOrder();
            },
            icon: Icon(CupertinoIcons.plus, color: Colors.black),
          )
        ],
      ),
      body: Content(),
    );
  }

  Widget Content(){

      if(loading == true){
        return Center(
          child: SpinKitWave(
            color: Colors.blue,
            size: 20.0,
          ),
        );
      }
      if (failed == true) {
        return ConnectionFailed(callback:(){
          getOrders(activeFilter);
        });
      }
      if(orders.length < 1){
        return Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Icon(CupertinoIcons.cube_box, size: 60,),
                ),
              ),
              Center(
                child: Text("${activeFilter}", style: TextStyle(fontFamily: "Lato_Bold", fontSize: 17),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text("You have no ${activeFilter.replaceAll("All", "")}", style: TextStyle(fontFamily: "Lato_Regular", fontSize: 15),),
                ),
              ),
              Center(
                child: CupertinoButton(
                  onPressed: (){
                    openNewOrder();
                  },
                  child: Text("Place an order"),
                ),
              ),
            ],
          ),
        );
      }
      return SmartRefresher(
        header: ClassicHeader(),
        footer: ClassicFooter(),
        enablePullDown: false,
        enablePullUp: true,
        onLoading: ()async{
          await getOrders(activeFilter);
          _refreshController.loadComplete();
        },
        controller: _refreshController,
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, i){
            return Card(
              child: InkWell(
                onTap: (){
                  Navigator.push(context, PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child:  OrderDetails(orderId: orders[i]['id'])));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(CupertinoIcons.cube_box_fill, color: Colors.white,),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(orders[i]['order_id'].padLeft(8,"0"), style: TextStyle(fontFamily: "Lato_Bold"),),
                                    Container(
                                      margin: EdgeInsets.only(top:3),
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: orders[i]['status'] == 'pending' ? Colors.orange : orders[i]['status'] == 'completed' ? Colors.blue : orders[i]['status'] == 'active' ? Colors.green : Colors.red,
                                      ),
                                      child: Text("${orders[i]['status']}",style: TextStyle(color: Colors.white,fontSize: 12),),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          Text(DateFormat("dd, MMM yyyy - h:m a").format(DateTime.parse(orders[i]['date_time_placed'])).toString(),style: TextStyle(fontSize: 12),)
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
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
                                child: Text(orders[i]['pickup_location'],),
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
                                child:  Text(orders[i]['dropoff_address']),
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(CupertinoIcons.cube_box),
                          ),
                          Flexible(child: Text(orders[i]['items'],style: TextStyle(fontFamily: "Lato_Regular"),))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
  }
}

