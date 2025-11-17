// lib/member/Updatepwd.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final dio=Dio();

class RequestPwdAuth extends StatefulWidget {
  final String mid;

  RequestPwdAuth({required this.mid}); // Findpwd에서 받은  생성자 mid 비밀번호 를 final String mid에 저장

  StaterequestPwdAuth createState() => StaterequestPwdAuth();
}
class StaterequestPwdAuth extends State<RequestPwdAuth> {



  TextEditingController mpwdCont = TextEditingController();
  TextEditingController mpwdCont2 = TextEditingController();

  void updatepwd() async{
    try{
      if(mpwdCont.text == mpwdCont2.text){
        print("비밀번호 일치");
      }else{
        print("비밀번호 불일치");
        return;
      }
      // State 직접적으로 호출 불가하니 widget으로 불러오기
      final obj = { "mid" : widget.mid , "mpwd" : mpwdCont.text };
      final response = await dio.put("http://10.164.103.46:8080/api/member/findpwd" , data: obj);
      final data = await response.data;
      print(data);

      showDialog(context: context, builder: (context) {
        return AlertDialog(
          content: Text(data['message']),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);

              if(data['success'] == true){
                Navigator.pushReplacementNamed(context, "/login");
              }
              },
                child: Text("확인"),
                ),
        ],
        );
      });
    }catch(e) {print(e); }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar( title: Text("비밀번호 재설정"),),
      body: Column(
        children: [
          TextField( controller: mpwdCont, decoration: InputDecoration(labelText: "새로운 비밀번호"),),
          TextField( controller: mpwdCont2, decoration: InputDecoration(labelText: "새로운 비밀번호"),),
          OutlinedButton(onPressed: updatepwd, child: Text("비밀번호 변경"), ),
        ],
      ) ,
    );
  }

}