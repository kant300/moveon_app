// lib/member/Login.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/Menu.dart';
import 'package:moveon_app/screens/onboarding/OnboardingCategory.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

class Login extends StatefulWidget {
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController midCont = TextEditingController();
  TextEditingController mpwdCont = TextEditingController();

  final Color mainColor = Color(0xFF3DE0D2);

  void login() async {
    try {
      final obj = {
        "mid": midCont.text,
        "mpwd": mpwdCont.text,
      };

      final response = await dio.post(
        "http://10.0.2.2:8080/api/member/login",
        data: obj,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      final data = response.data;
      print(data);

      if (data['status'] == "Login") {
        final localsave = await SharedPreferences.getInstance();

        if (data['token'] != null) {
          await localsave.setString('logintoken', data['token']);
          await localsave.remove('guestToken');
          await localsave.setString('mname', data['member']['mname']);

          final wishlist = data['member']['wishlist'];

          // 신규 사용자 → 온보딩 카테고리로
          if (wishlist == null || wishlist == "") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => OnboardingCategory()),
                  (router) => false,
            );
          } else {
            Navigator.pushNamed(context, "/");
          }
        }
      }
    } catch (e) {
      print("로그인 실패 $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 실패. 아이디/비밀번호를 확인해주세요.")),
      );
    }
  }

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
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F8),
      appBar: AppBar(
        title: Text(
          "로그인",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            SizedBox(height: 40),

            // ---------------- 로그인 카드 ----------------
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
                    "환영합니다!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "로그인 후 다양한 서비스를 이용하세요.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: 30),

                  // 아이디 입력
                  TextField(
                    controller: midCont,
                    decoration: _inputDeco("아이디"),
                  ),
                  SizedBox(height: 20),

                  // 비밀번호 입력
                  TextField(
                    controller: mpwdCont,
                    obscureText: true,
                    decoration: _inputDeco("비밀번호"),
                  ),

                  SizedBox(height: 10),

                  // 아이디/비밀번호 찾기
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/findid");
                        },
                        child: Text(
                          "아이디 찾기",
                          style: TextStyle(color: mainColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/findpwd");
                        },
                        child: Text(
                          "비밀번호 찾기",
                          style: TextStyle(color: mainColor),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "로그인",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // ---------------- 회원가입 이동 ----------------
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, "/signup");
              },
              child: Text(
                "아직 계정이 없나요? 회원가입 →",
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
