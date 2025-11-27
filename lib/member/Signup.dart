// lib/member/Signup.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/screens/onboarding/OnboardingStart.dart';

final dio = Dio();

class Signup extends StatefulWidget {
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup> {

  // 회원가입 입력창
  TextEditingController newmid = TextEditingController();
  TextEditingController newmpwd = TextEditingController();
  TextEditingController newmname = TextEditingController();
  TextEditingController newmphone = TextEditingController();
  TextEditingController newmemail = TextEditingController();

  final Color mainColor = Color(0xFF3DE0D2);

  void signup() async {
    try {
      final obj = {
        "mid": newmid.text,
        "mpwd": newmpwd.text,
        "mphone": newmphone.text,
        "mname": newmname.text,
        "memail": newmemail.text,
      };

      final response =
      await dio.post("http://10.95.125.46:8080/api/member/signup", data: obj);
      final data = response.data;
      print(data);

      if (data == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OnboardingStart()),
        );
      }
    } catch (e) {
      print("회원가입 오류 : $e");
    }
  }

  InputDecoration inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
          title: Text("회원가입", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),

              // 카드 UI
              Container(
                padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타이틀
                    Row(
                      children: [
                        Icon(Icons.person_add_alt_1,
                            size: 30, color: mainColor),
                        SizedBox(width: 10),
                        Text(
                          "회원가입",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    Text(
                      "아래 정보를 입력 후 회원가입을 완료해주세요.",
                      style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),

                    SizedBox(height: 25),

                    // 입력창들
                    TextField(
                      controller: newmid,
                      decoration: inputDeco("아이디"),
                    ),
                    SizedBox(height: 15),

                    TextField(
                      controller: newmpwd,
                      obscureText: true,
                      decoration: inputDeco("비밀번호"),
                    ),
                    SizedBox(height: 15),

                    TextField(
                      controller: newmname,
                      decoration: inputDeco("이름"),
                    ),
                    SizedBox(height: 15),

                    TextField(
                      controller: newmphone,
                      decoration: inputDeco("휴대폰 번호"),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),

                    TextField(
                      controller: newmemail,
                      decoration: inputDeco("이메일"),
                      keyboardType: TextInputType.emailAddress,
                    ),

                    SizedBox(height: 30),

                    // 회원가입 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "회원가입 완료",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
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
