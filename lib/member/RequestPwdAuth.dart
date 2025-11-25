// lib/member/Updatepwd.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final dio = Dio();

class RequestPwdAuth extends StatefulWidget {
  final String mid;

  RequestPwdAuth({required this.mid});

  StaterequestPwdAuth createState() => StaterequestPwdAuth();
}

class StaterequestPwdAuth extends State<RequestPwdAuth> {
  TextEditingController mpwdCont = TextEditingController();
  TextEditingController mpwdCont2 = TextEditingController();

  final Color mainColor = Color(0xFF3DE0D2);

  void updatepwd() async {
    try {
      if (mpwdCont.text.trim() != mpwdCont2.text.trim()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("비밀번호가 일치하지 않습니다.")));
        return;
      }

      final obj = {"mid": widget.mid, "mpwd": mpwdCont.text};
      final response = await dio.put(
        "http://10.0.2.2:8080/api/member/findpwd",
        data: obj,
      );

      final data = response.data;
      print(data);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(data['message'] ?? "오류가 발생했습니다."),
          actions: [
            TextButton(
              onPressed: () {
                if (data['success'] == true) {
                  Navigator.pushReplacementNamed(context, "/onboardingStart");
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text("확인"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("비밀번호 변경 오류 : $e");
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
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F8),
      appBar: AppBar(
        title: Text("비밀번호 재설정", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 30),

            // 카드 박스
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
                  // 아이콘 + 타이틀
                  Row(
                    children: [
                      Icon(Icons.lock_reset, size: 32, color: mainColor),
                      SizedBox(width: 10),
                      Text(
                        "새로운 비밀번호 설정",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Text(
                    "보안을 위해 새로운 비밀번호를 입력해주세요.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),

                  SizedBox(height: 25),
                  TextField(
                    controller: mpwdCont,
                    obscureText: true,
                    decoration: inputDeco("새로운 비밀번호"),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: mpwdCont2,
                    obscureText: true,
                    decoration: inputDeco("비밀번호 재입력"),
                  ),

                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updatepwd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "비밀번호 변경",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
