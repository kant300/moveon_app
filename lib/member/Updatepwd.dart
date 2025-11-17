// lib/member/Updatepwd.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio=Dio();

class Updatepwd extends StatefulWidget{
  StateUpdatepwd createState() => StateUpdatepwd();
}
class StateUpdatepwd extends State<Updatepwd> {

  TextEditingController mpwdCont = TextEditingController();
  TextEditingController upmpwdCont = TextEditingController();

  void updatepwd() async {
    try {
      final localsvae = await SharedPreferences.getInstance();
      final token = localsvae.getString("logintoken");

      final obj = {
        "mpwd": mpwdCont.text,
        "newPwd": upmpwdCont.text,
      };
      final response = await dio.put(
        "http://10.164.103.46:8080/api/member/updatePwd", data: obj,
        options: Options(headers: { "Authorization": "Bearer $token",}),
      );
      final data = await response.data;
      print(data);

      showDialog(context: context, builder: (context) {
        return AlertDialog(
            content: Text(data['message']),
            actions: [
            TextButton(onPressed: ()
        {
          Navigator.pop(context);
          if (data['success'] == true) {
            Navigator.pushReplacementNamed(context, "/setting");
          }
        }, child: Text("확인"),
        ),
        ]
        ,
        );
      });
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar( title: Text("비밀번호 변경 페이지"),),
      body: Column(
        children: [
          TextField(controller: mpwdCont, decoration: InputDecoration(labelText: "기존 비밀번호"),),
          TextField(controller: upmpwdCont, decoration: InputDecoration(labelText: "새로운 비밀번호"),),
          OutlinedButton(onPressed: updatepwd, child: Text("비밀번호 변경"),),
        ],
      ),
    );
  }
}