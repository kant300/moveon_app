// lib/member/Findpwd.dart

import 'dart:async';

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

  // 타이머 변수
  Timer? timer;
  int seconds = 0; // 타이머 남은 시간

  String get timerText {
    int m = seconds ~/ 60; // 분
    int s = seconds % 60; // 초
    return "${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}";
  }

  // 타이머 시작
  void starttime() {
    seconds = 180; // 3분
    timer?.cancel(); // 기존 실행 중 타이머 종료

    // 타이머가 초마다 감소
    timer = Timer.periodic(Duration(seconds : 1), (t) {
      if (seconds > 0 ) {
        setState(() {
          seconds--;
        });
      }else { // 시간없으면 종료
        t.cancel();
      }
    });
  }

  // 인증성공시 종료
  void stoptime() {
    timer?.cancel();
  }
  bool mcode = false;
  dynamic midlist = '';
  void requestPwdAuth() async{
    try{
      final obj = {
        "mid" : midCont.text ,
        "memail" : memailCont.text ,
      };
      final response = await dio.post("http://10.0.2.2:8080/api/member/requestPwdAuth" , data: obj);
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
        starttime();
      }

    }catch(e) { print('비밀번호 찾기 에러 $e'); }
  }

  void mcodecheck() async{
    try{
      final obj = {
        "mid" : midCont.text ,
        "verifyCode" : mcodeCont.text ,
      };
      final response = await dio.post("http://10.0.2.2:8080/api/member/verifyPwdCode" , data: obj );
      final data = await response.data;
      stoptime(); // 성공시 멈춤
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
    return WillPopScope(onWillPop: () async {
      Navigator.pushReplacementNamed(context, "/onboardingStart");
      return false;
    },

        child: Scaffold(
          appBar: AppBar(title: Text("비밀번호찾기"),),
          body: Column(children: [
            TextField(controller: midCont,
              decoration: InputDecoration(labelText: "아이디"),),
            TextField(controller: memailCont,
              decoration: InputDecoration(labelText: "이메일"),),
            OutlinedButton(onPressed: () {
              requestPwdAuth();
              starttime();
            }, child: Text("인증번호 발급"),),

            if(mcode)...[ // ... 조건이 참일때
              SizedBox(height: 10),
              TextField(controller: mcodeCont,
                decoration: InputDecoration(labelText: "인증번호 입력"),),Text("남은시간 $timerText"),
              ElevatedButton(onPressed: mcodecheck, child: Text("인증확인"),),
            ]
          ],
          ),
        ));
  }
    @override
    void dispose() {
      timer?.cancel();
      super.dispose();
  }
}