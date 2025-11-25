// lib/member/Findid.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final dio = Dio();

class Findid extends StatefulWidget {
  FindidState createState() => FindidState();
}

class FindidState extends State<Findid> {
  TextEditingController memailCont = TextEditingController();
  TextEditingController mphoneCont = TextEditingController();

  final Color mainColor = Color(0xFF3DE0D2);

  void findid() async {
    try {
      final obj = {
        "memail": memailCont.text,
        "mphone": mphoneCont.text,
      };
      final response = await dio.get(
        "http://10.0.2.2:8080/api/member/findid",
        queryParameters: obj,
      );

      final data = response.data;
      print(data);

      if (data != null && data['mid'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("회원님의 아이디는 : ${data['mid']}"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("일치하는 회원 정보가 없습니다."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('아이디찾기 에러 $e');
    }
  }

  // 입력창 스타일 공통
  InputDecoration _inputDeco(String label) {
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/onboardingStart");
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF4F7F8),
        appBar: AppBar(
          title: Text("아이디 찾기", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),

              // ---------------- 카드 영역 ----------------
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
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "회원 정보로 아이디 찾기",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),

                    Text(
                      "가입 시 입력한 이메일과 전화번호를 입력해주세요.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                    SizedBox(height: 25),

                    // 이메일 입력
                    TextField(
                      controller: memailCont,
                      decoration: _inputDeco("이메일"),
                    ),
                    SizedBox(height: 20),

                    // 전화번호 입력
                    TextField(
                      controller: mphoneCont,
                      decoration: _inputDeco("전화번호"),
                      keyboardType: TextInputType.phone,
                    ),

                    SizedBox(height: 30),

                    // 아이디 찾기 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: findid,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "아이디 찾기",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // 로그인 페이지 이동 링크
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, "/login");
                },
                child: Text(
                  "이미 아이디가 있으신가요? 로그인하기 →",
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
