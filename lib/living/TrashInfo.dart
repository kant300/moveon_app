import 'package:flutter/material.dart';

class TrashInfo extends StatefulWidget {
  TrashInfoState createState() => TrashInfoState();
}

class TrashInfoState extends State<TrashInfo> {
  void getTrashData() async {
    try {

    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("쓰레기 배출 정보")
        ],
      ),
    );
  }
}