// lib/member/Updatepwd.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

class Updatepwd extends StatefulWidget {
  StateUpdatepwd createState() => StateUpdatepwd();
}

class StateUpdatepwd extends State<Updatepwd> {
  TextEditingController mpwdCont = TextEditingController();
  TextEditingController upmpwdCont = TextEditingController();

  final Color mainColor = Color(0xFF3DE0D2);

  void updatepwd() async {
    try {
      final localsave = await SharedPreferences.getInstance();
      final token = localsave.getString("logintoken");

      final obj = {"mpwd": mpwdCont.text, "newPwd": upmpwdCont.text};

      final response = await dio.put(
        "http://10.95.125.46:8080/api/member/updatePwd",
        data: obj,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final data = response.data;
      print(data);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(data['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (data['success'] == true) {
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
        title: Text("비밀번호 변경", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline, size: 30, color: mainColor),
                      SizedBox(width: 10),
                      Text(
                        "비밀번호 변경",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 10),
                  Text(
                    "보안을 위해 기존 비밀번호 입력 후\n새로운 비밀번호를 설정하세요.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),

                  SizedBox(height: 25),

                  TextField(
                    controller: mpwdCont,
                    obscureText: true,
                    decoration: inputDeco("기존 비밀번호"),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: upmpwdCont,
                    obscureText: true,
                    decoration: inputDeco("새로운 비밀번호"),
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
                        "변경하기",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
