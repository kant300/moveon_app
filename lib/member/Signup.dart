// lib/member/Signup.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/screens/onboarding/OnboardingStart.dart';

final dio = Dio();

class Signup extends StatefulWidget{
  SignupState createState()=> SignupState();
}
class SignupState extends State<Signup> {

  // 회원가입
  TextEditingController newmid = TextEditingController(); // 아이디
  TextEditingController newmpwd = TextEditingController(); // 비밀번호
  TextEditingController newmphone = TextEditingController(); // 폰
  TextEditingController newmname = TextEditingController(); // 이름
  TextEditingController newmemail = TextEditingController(); // 이메일ㅂㅈ

  void signup() async{
    try{
      final obj = {
        "mid" : newmid.text,
        "mpwd" : newmpwd.text,
        "mphone" : newmphone.text,
        "mname" : newmname.text,
        "memail" : newmemail.text,

      };
      final response = await dio.post("http://10.95.125.46:8080/api/member/signup" , data: obj);
      final data = await response.data;
      print(data);
      if(data == true ) { Navigator.pushReplacement(context , MaterialPageRoute(builder: (_) => OnboardingStart()),); }
      print("성공");
    }catch(e) { print(e); }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar( title: Text("회원가입"),),
      body: Column(
        children: [
          TextField( controller: newmid  , decoration: InputDecoration( labelText: "아이디"),),
          TextField( controller: newmpwd , decoration: InputDecoration( labelText: "비밀번호"), ),
          TextField( controller: newmname , decoration: InputDecoration( labelText: "이름"), ),
          TextField( controller: newmphone , decoration: InputDecoration( labelText: "휴대폰"), ),
          TextField( controller: newmemail , decoration: InputDecoration( labelText: "이메일"), ),

          Text("회원가입"),
          OutlinedButton(onPressed: signup, child: Text("회원가입") ),
        ],
      ),
    );
  }

}