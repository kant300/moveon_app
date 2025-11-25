// lib/member/Setting.dart


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio=Dio();

class Setting extends StatefulWidget{
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {

  // 로그인 정보 넘겨주기
  void loginsave() async{
    final loginho = await SharedPreferences.getInstance();
    final token = await loginho.getString("logintoken");
    try{
      final response = await dio.get("http://10.0.2.2:8080/api/member/info" ,
      options: Options(headers: { "Authorization" : "Bearer $token" ,}),
      );
      final data = await response.data;
      print(data);
    }catch(e) { print(e); }
  }

  // 로그아웃
  void logout() async {
    try {
      // localsave에 로컬저장소 저장
      final localsave = await SharedPreferences.getInstance();
      // 로컬 저장소에 저장한 localsave를 token 에 받기
      final token = localsave.getString('logintoken');
      // 서버로부터 정보불러오는데 token 확인
      final response = await dio.get("http://10.0.2.2:8080/api/member/logout",
        options: Options(headers: { "Authorization": "Bearer $token",}),
      );
      final data = await response.data;
      print(data);

      if (data['Logout'] == '로그아웃성공 ') {
        print("로그아웃 토큰 :  $token");
      }

        // 로그인한 토큰 / 사용자 정보 삭제
        await localsave.remove('logintoken');
        await localsave.remove('mname');

        Navigator.pushReplacementNamed(context, '/onboardingStart');
      } catch (e) {
      print(e);
    }
  }
  // 회원탈퇴
  void signout() async{
    try{
      final localsave = await SharedPreferences.getInstance();
      final token = localsave.getString('logintoken');
      final response = await dio.delete("http://10.0.2.2:8080/api/member/signout" ,
       options: Options(headers: {"Authorization": "Bearer $token",}),
      );
      final data = await response.data;
      if(data == true){
        print("회원탈퇴 : $token");
        await localsave.clear();
        print("정보 삭제");
        Navigator.pushReplacementNamed(context, "/onboardingStart");
      }

    }catch(e) { print("로그아웃 실패 $e"); }
  }

  void passwordupdate() async{
    try{
    }catch(e) { print(e); }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar( title: Text(" 설정 "),),
      body: Column( children: [
        OutlinedButton(onPressed: logout , child: Text("로그아웃"), ),
        OutlinedButton(onPressed: signout , child: Text("회원탈퇴"), ),
        Text(" 계정 관리"),
        TextButton(onPressed: (){ Navigator.pushNamed(context, "/profile");},  child: Text("프로필 수정"), ),
        TextButton(onPressed: () { Navigator.pushNamed(context, "/updatepwd");} , child: Text("비밀번호 변경"), ),
        TextButton(onPressed: (){}, child: Text("개인정보 관리"), ),
      ],),
    );
  }
}