// lib/member/Findpwd.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final dio= Dio();
class Findpwd extends StatefulWidget {
  FindpwdState createState() => FindpwdState();
}

class FindpwdState extends State<Findpwd>{

  TextEditingController midCont = TextEditingController();
  TextEditingController memailCont = TextEditingController();
  TextEditingController mcodeCont = TextEditingController();

  bool mcode = false;
  dynamic midlist = '';
  void requestPwdAuth() async{
    try{
      final obj = {
        "mid" : midCont.text ,
        "memail" : memailCont.text ,
      };
      final response = await dio.post("http://localhost:8080/api/member/requestPwdAuth" , data: obj);
      final data = await response.data;
      print(data);
      if(data['success'] == true ){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content : Text(data['message'])),// 메세지 전송 문구 출력
        );
        setState(() {
          mcode = true; // 기본적 false 숨기기 / true 면 화면상 보이기
        });

      }


    }catch(e) { print('비밀번호 찾기 에러 $e'); }
  }

  void mcodecheck() async{
    try{
      final obj = {
        "mid" : midCont.text ,
        "verifyCode" : mcodeCont.text ,
      };
      final response = await dio.post("http://localhost:8080/api/member/verifyPwdCode" , data: obj );
      final data = await response.data;
      if(data['success'] == true){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])),
        );
      }
    }catch(e){ print("인증 실패 $e");}
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar( title: Text("비밀번호찾기"),),
      body: Column( children: [
        TextField( controller: midCont , decoration: InputDecoration(labelText: "아이디"), ),
        TextField( controller: memailCont , decoration: InputDecoration(labelText: "이메일"), ),
        OutlinedButton(onPressed: requestPwdAuth, child: Text("인증번호 발급"), ),

        if(mcode)...[ // ... 조건이 참일때
          TextField( controller: mcodeCont, decoration: InputDecoration(labelText: "인증번호 입력"), ),
          ElevatedButton(onPressed: mcodecheck , child: Text("인증확인"), ),
          ]
      ],),
    );
  }
}