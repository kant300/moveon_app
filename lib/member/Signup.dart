// lib/member/Signup.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
  TextEditingController newmemail = TextEditingController(); // 이메일
  TextEditingController newaddress1 = TextEditingController(); // 주소1 시
  TextEditingController newaddress2 = TextEditingController(); // 동
  TextEditingController newaddress3 = TextEditingController(); // 구

  void signup() async{
    try{
      final obj = {
        "mid" : newmid.text,
        "mpwd" : newmpwd.text,
        "mphone" : newmphone.text,
        "mname" : newmname.text,
        "memail" : newmemail.text,
        "maddress1" : newaddress1.text,
        "maddress2" : newaddress2.text,
        "maddress3" : newaddress3.text,

      };
      final response = await dio.post("http://localhost:8080/api/member/signup" , data: obj);
      final data = await response.data;
      print(data);
      if(data == true ) { Navigator.pop(context , true); }
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
          TextField( controller: newmid  ),
          TextField( controller: newmpwd  ),
          TextField( controller: newmname  ),
          TextField( controller: newmphone  ),
          TextField( controller: newmemail  ),
          TextField( controller: newaddress1  ),
          TextField( controller: newaddress2  ),
          TextField( controller: newaddress3  ),
          Text("회원가입"),
          OutlinedButton(onPressed: signup, child: Text("회원가입") ),
        ],
      ),
    );
  }

}