// lib/member/Findpwd.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/member/RequestPwdAuth.dart';

final dio = Dio();

class Findpwd extends StatefulWidget {
  FindpwdState createState() => FindpwdState();
}

class FindpwdState extends State<Findpwd> {
  TextEditingController midCont = TextEditingController();
  TextEditingController memailCont = TextEditingController();
  TextEditingController mcodeCont = TextEditingController();

  final Color mainColor = Color(0xFF3DE0D2);

  // 타이머 변수
  Timer? timer;
  int seconds = 0;

  String get timerText {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void starttime() {
    seconds = 180; // 3분
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
      }
    });
  }

  void stoptime() {
    timer?.cancel();
  }

  bool mcode = false;

  void requestPwdAuth() async {
    try {
      final obj = {"mid": midCont.text, "memail": memailCont.text};

      final response = await dio.post(
        "http://10.95.125.46:8080/api/member/requestPwdAuth",
        data: obj,
      );
      final data = response.data;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(data["message"]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("확인")),
          ],
        ),
      );

      if (data['success'] == true) {
        setState(() => mcode = true);
        starttime();
      }
    } catch (e) {
      print("비밀번호 찾기 에러 $e");
    }
  }

  void mcodecheck() async {
    try {
      final obj = {"mid": midCont.text, "verifyCode": mcodeCont.text};

      final response = await dio.post(
        "http://10.95.125.46:8080/api/member/verifyPwdCode",
        data: obj,
      );
      final data = response.data;
      stoptime();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(data['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (data['success'] == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestPwdAuth(mid: midCont.text),
                    ),
                  );
                }
              },
              child: Text("확인"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("인증 확인 에러 $e");
    }
  }

  InputDecoration inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: mainColor, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/onboardingStart");
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF4F7F8),
        appBar: AppBar(
          title: Text("비밀번호 찾기", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 30),

              // ---------------- 카드 ----------------
              Container(
                padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "비밀번호 재설정",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "회원님의 아이디와 이메일을 입력하시면 인증번호를 보내드립니다.",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),

                    SizedBox(height: 30),

                    TextField(controller: midCont, decoration: inputDeco("아이디")),
                    SizedBox(height: 20),
                    TextField(controller: memailCont, decoration: inputDeco("이메일")),

                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: requestPwdAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("인증번호 발급",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),

                    if (mcode) ...[
                      SizedBox(height: 25),
                      Divider(),

                      SizedBox(height: 15),
                      Text("이메일로 전송된 인증번호를 입력해주세요.",
                          style:
                          TextStyle(color: Colors.black87, fontSize: 14)),
                      SizedBox(height: 15),

                      TextField(
                        controller: mcodeCont,
                        decoration: inputDeco("인증번호 입력"),
                      ),
                      SizedBox(height: 10),

                      Text(
                        "남은 시간: $timerText",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: mcodecheck,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("인증 확인",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
