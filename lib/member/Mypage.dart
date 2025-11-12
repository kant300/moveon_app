// lib/member/Mypage.dart


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio=Dio();

class Mypage extends StatefulWidget{
  MypageState createState() => MypageState();
}

class MypageState extends State<Mypage> {

  // 로그아웃
  void logout() async {
    try {
      // localsave에 로컬저장소 저장
      final localsave = await SharedPreferences.getInstance();
      // 로컬 저장소에 저장한 localsave를 token 에 받기
      final token = localsave.getString('logintoken');
      // 서버로부터 정보불러오는데 token 확인
      final response = await dio.get("http://localhost:8080/api/member/logout",
        options: Options(headers: { "Authorization": "Bearer $token",}),
      );
      final data = await response.data;
      print(data);

      if (data['Logout'] == '로그아웃성공 ') {
        print("로그아웃 토큰 $token",);
      }

        // 로그인한 토큰 / 사용자 정보 삭제
        await localsave.remove('logintoken');
        await localsave.remove('mname');

        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
      print(e);
    }
  }

  // 회원탈퇴
  void signout() async{
    try{

    }catch(e) { print("로그아웃 실패 $e"); }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar( title: Text("마이페이지? 설정 "),),
      body: Column( children: [
        TextButton(onPressed: logout , child: Text("로그아웃"), ),
        TextButton(onPressed: signout , child: Text("회원탈퇴"), )
      ],),
    );
  }
}