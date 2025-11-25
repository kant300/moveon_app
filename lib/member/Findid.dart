// lib/member/Findid.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final dio= Dio();
class Findid extends StatefulWidget {
  FindidState createState() => FindidState();
}

class FindidState extends State<Findid>{

  TextEditingController memailCont = TextEditingController();
  TextEditingController mphoneCont = TextEditingController();

  void findid() async{
    try{
      final obj = {
        "memail" : memailCont.text ,
        "mphone" : mphoneCont.text ,
      };
      final response = await dio.get("http://10.0.2.2:8080/api/member/findid" , queryParameters: obj);
      final data = await response.data;
      print(data);
      if(data != null && data['mid'] != null){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("회원님의 아이디는 : ${data['mid']} ")) , );
      }


    }catch(e) { print('아이디찾기 에러 $e'); }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WillPopScope(
      onWillPop: () async{
        Navigator.pushReplacementNamed(context, "/onboardingStart");
        return false;
      },
    child:  Scaffold(
      appBar: AppBar( title: Text("아이디찾기"),),
      body: Column( children: [
        Text("아이디찾기페이지"),
        TextField( controller: memailCont , decoration: InputDecoration(labelText: "이메일"), ),
        TextField( controller: mphoneCont , decoration: InputDecoration(labelText: "폰"), ),
        OutlinedButton(onPressed: findid, child: Text("아이디찾기") ),

      ],),
    )
    );
  }
}