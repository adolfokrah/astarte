import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConnectionFailed extends StatelessWidget {
  final callback;
  const ConnectionFailed({Key key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.wifi, size: 200, color: Colors.black26),
          Text("Oops! couldn't fetch orders",
              style: TextStyle(
                  fontFamily: "Lato_Regular",
                  fontSize: 20,
                  color: Colors.black45)),
          CupertinoButton(
              onPressed: (){
                callback();
              },
              child:
              Text("RELOAD", style: TextStyle(fontFamily: "Lato_Bolf")))
        ],
      ),
    );
  }
}
