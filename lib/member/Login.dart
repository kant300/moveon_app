// lib/member/Login.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

class Login extends StatefulWidget{
  LoginState createState()=> LoginState();
}
class LoginState extends State<Login> {

  dynamic test = {};


  // 로그인
  TextEditingController midCont = TextEditingController(); // 아이디
  TextEditingController mpwdCont = TextEditingController(); // 비밀번호

  void login() async{
    try {
      final obj = {
        "mid": midCont.text,
        "mpwd": mpwdCont.text,
      };
      final response = await dio.post(
        "http://10.164.103.46:8080/api/member/login", data: obj,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      final data = await response.data;
      print(data);
      print(obj);
      if (data != null) {
        setState(() {
          test = data['member'];
        });

      final localsave = await SharedPreferences.getInstance();
      if(data['token'] != null ){
        await localsave.setString('logintoken', data['token'] );
        print(localsave);
        print("토큰 저장 : ${data['token']}");
      }
      await localsave.setString('mname', data['member']['mname']);

      print("로그인 성공");

        Navigator.pop(context, {
          'mname': data['member']['mname'], // 이름 전달
        });

    }
    }catch(e) { print("로그인 실패 $e") ; }
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar( title: Text("로그인"),),
      body: Column(
        children: [
          TextField( controller: midCont  ),
          TextField( controller: mpwdCont  ),


          TextButton(onPressed: (){ Navigator.pushNamed(context, "/findid"); } , child: Text("아이디찾기"), ),
          TextButton(onPressed: (){ Navigator.pushNamed(context, "/findpwd"); } , child: Text("비밀번호찾기"), ),

          OutlinedButton(onPressed: login, child: Text("로그인") ),
          TextButton(onPressed: (){Navigator.pushNamed(context, "/signup"); },
            child: Text("회원가입 페이지로 이동"),),

          


        ],
      ),
    );
  }

}