// lib/member/Findpwd.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/member/RequestPwdAuth.dart';

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
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          content: Text(data["message"]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), child: Text("확인"),
            ),
          ],
        );
      });
      if(data['success'] == true ){
        setState(() {
          mcode = true;
        });
      };

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
      print(data);

      // 팝업창
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          content: Text(data['message']),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);

              if (data['success'] == true) { // 비밀번호 찾을때 받은 mid 정보 Updatepwd에 넘기기  왜? 누구 꺼인지 알아야 하니까
                Navigator.push(context, MaterialPageRoute(builder: (_) => RequestPwdAuth( mid : midCont.text),),);
              }
            },
              child: Text("확인"),
            ),
          
          ],
        );
      });
    }catch(e){ print(e);}
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
          ElevatedButton(onPressed: mcodecheck  , child: Text("인증확인"), ),
          ]

      ],),
    );
  }
}