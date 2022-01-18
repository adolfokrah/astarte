
import 'dart:convert';

import 'package:astarte/config.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class DeliveryController extends GetxController{
  var filters = ["All Orders","Pending Orders","Ongoing Orders","Cancelled Orders","Completed Orders"].obs;
  var activeFilter = 'All Orders'.obs;
  var orders = [].obs;
  var order = {}.obs;
  var loading = true.obs;
  var fetchingOrder = true.obs;
  var userId = "0".obs;
  var fetchOrdersStart = 0.obs;
  var failed = false.obs;
  var failedFetchingOrder = false.obs;


  Config appConfiguration = Config();


  @override
  void onInit()async{
    super.onInit();
    await getUserDetails();
    getOrders(activeFilter.value);
  }

  getUserDetails() async {
    try {
      SharedPreferences storage = await SharedPreferences.getInstance();
      String userDetails = storage.getString('userDetails');
      if (userDetails != null) {
        var userDetailsArray = jsonDecode(userDetails);
        userId.value = userDetailsArray['user_id'].toString();
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  updateFilter(filter)=>activeFilter.value = filter;

  getOrders(status)async{
      try{

        if(status != activeFilter.value){
          fetchOrdersStart.value = 0;
          orders.value = [];
        }

        if(orders.length < 1){
          loading.value = true;
        }
        activeFilter.value = status;
        var data ={
          "user_id": userId.value,
          "start":fetchOrdersStart.toString(),
          "records":"5",
          "status":status
        };
        var url = appConfiguration.apiBaseUrl + 'fetch_user_orders.php';
        var response = await http.post(Uri.parse(url), body: data);


        failed.value = false;
        if(jsonDecode(response.body).length > 0){
          fetchOrdersStart += 5;
        }

        if(orders.length > 0){
          orders.value = [...orders, ...jsonDecode(response.body)];
        }else{
          orders.value = jsonDecode(response.body);
        }
      }catch(e){
        if(orders.length < 1) failed.value = true;
      }finally{
        loading.value = false;
      }
  }

  getOder(orderId)async{
    try{
      fetchingOrder.value = true;
      var data ={
        "order_id": orderId,
      };
      var url = appConfiguration.apiBaseUrl + 'fetch_order.php';
      var response = await http.post(Uri.parse(url), body: data);
      order.value = jsonDecode(response.body);
      failedFetchingOrder.value = false;
    }catch(e){
      print(e);
      failedFetchingOrder.value = true;
    }finally{
      fetchingOrder.value = false;
    }
  }
}
