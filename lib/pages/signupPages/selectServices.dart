import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';

void main(){
  runApp(SelectServices());
}

class SelectServices extends StatefulWidget {

  final selectedServices;

  SelectServices({Key key, @required this.selectedServices}) : super(key: key);

  @override
  _SelectServicesState createState() => _SelectServicesState();
}

class _SelectServicesState extends State<SelectServices> {
  Config appConfiguration = new Config();
  var loading = false;
  var selectedServices = [];
  var allServices;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStyles();
    if(!mounted) return;
    setState(() {
      selectedServices = widget.selectedServices;
    });
  }

  void getStyles()async{
    if(!mounted) return;
    setState(() {
      loading = true;
    });
    var url = appConfiguration.apiBaseUrl + 'getServices.php';
    var response = await http.get(url);
    if(!mounted) return;
    setState(() {
      allServices = jsonDecode(response.body)['styles'];
      loading = false;
    });

  }

  void processForm(){
    if(selectedServices.length < 1){
      Fluttertoast.showToast(
          msg: "Please select your services.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }

    Navigator.pop(context, selectedServices);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: appConfiguration.appColor),
      title: "Select your services",
      home: LoadingOverlay(
        isLoading : loading,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Text("Select your services", style: TextStyle(fontFamily: "Lato_Black",color: Colors.black),),
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
          body: content(),
        ),
      ),
    );
  }

  Widget content(){
    return Container(
      color: Colors.white,
      child: Form(
        key: this._formKey,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                    controller: this._typeAheadController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(15),
                        fillColor: Colors.black12,
                        filled: true,
                        hintText: "Service",
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
                    )
                ),
                suggestionsCallback: (pattern) async{

                  var m = [];
                  for(var i=0; i<allServices.length; i++){
                    m.add(allServices[i]);
                  }
                  var n = m.where((f) => f.toLowerCase().contains(pattern.toLowerCase())).toList();
                  return n;
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (suggestion) {
                  this._typeAheadController.text = "";
                  var n = selectedServices;
                  if(!(n.contains(suggestion))){
                    n.add(suggestion);
                    if(mounted){
                      setState(() {
                        selectedServices = n;
                      });
                    }
                  }

                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please select a servce';
                  }
                  return null;
                },

              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ListView.separated(
                    itemCount: selectedServices.length,
                    separatorBuilder: (context,index){
                      return Divider();
                    },
                    itemBuilder: (context,index){
                      return ListTile(
                        title: Text(selectedServices[index],style: TextStyle(fontFamily: "Lato_Regular"),),
                        trailing: IconButton(
                          onPressed: (){
                            var n = selectedServices;
                            n.remove(selectedServices[index]);
                            setState(() {
                              selectedServices = n;
                            });
                          },
                          icon: Icon(Icons.delete),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );

  }
}
