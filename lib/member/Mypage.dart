// lib/member/Mypage.dart


import 'package:flutter/material.dart';
import 'package:moveon_app/main.dart';

class Mypage extends StatefulWidget{
  MypageState createState() => MypageState();
}

class MypageState extends State<Mypage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar( title: Text("마이페이지 "),),
    );
  }
}