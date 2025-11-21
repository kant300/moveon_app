// lib/member/Login.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/Menu.dart';
import 'package:moveon_app/screens/onboarding/OnboardingCategory.dart';
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

  void login() async {
    try {
      final obj = {
        "mid": midCont.text,
        "mpwd": mpwdCont.text,
      };
      final response = await dio.post(
        "http://10.95.125.46:8080/api/member/login", data: obj,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      final data = await response.data;
      print(data);

      if (data['status'] == "Login") {
        final localsave = await SharedPreferences.getInstance();
        if (data['token'] != null) {
          await localsave.setString('logintoken', data['token']);
          print(localsave);
          // 게스트 토크 제거
          await localsave.remove('guestToken');
          await localsave.setString('mname', data['member']['mname']);

          final member = data['member'];
          final wishlist = member['wishlist']; // null 기준 확이용ㅇ 회원 신규잡기

          if (wishlist == null || wishlist == "") {
            print("신규 사용자");
            Navigator.pushReplacementNamed(context, "/onboardingCategory");
          } else {
            print("그냥 사용자");
            Navigator.pushReplacementNamed(context, "/menu" );
            print("토큰 저장 : ${data['token']}");
          }
        }
        print("로그인 성공");
      }
    } catch (e) {
      print("로그인 실패 $e");
    }
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


          TextButton(onPressed: (){ Navigator.pushReplacementNamed(context, "/findid"); } , child: Text("아이디찾기"), ),
          TextButton(onPressed: (){ Navigator.pushReplacementNamed(context, "/findpwd"); } , child: Text("비밀번호찾기"), ),

          OutlinedButton(onPressed: login, child: Text("로그인") ),
          TextButton(onPressed: (){Navigator.pushReplacementNamed(context, "/signup"); },
            child: Text("회원가입 페이지로 이동"),),

        ],
      ),
    );
  }

}