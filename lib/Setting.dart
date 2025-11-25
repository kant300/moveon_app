import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

class Setting extends StatefulWidget {
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {
  // 로그아웃
  void logout() async {
    try {
      final localsave = await SharedPreferences.getInstance();
      final token = localsave.getString('logintoken');

      final response = await dio.get(
        "http://10.0.2.2:8080/api/member/logout",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print(response.data);

      await localsave.remove('logintoken');
      await localsave.remove('mname');

      Navigator.pushReplacementNamed(context, '/onboardingStart');
    } catch (e) {
      print("로그아웃 오류: $e");
    }
  }

  // 회원탈퇴
  void signout() async {
    try {
      final localsave = await SharedPreferences.getInstance();
      final token = localsave.getString('logintoken');

      final response = await dio.delete(
        "http://10.0.2.2:8080/api/member/signout",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.data == true) {
        await localsave.clear();
        Navigator.pushReplacementNamed(context, "/onboardingStart");
      }
    } catch (e) {
      print("회원탈퇴 오류: $e");
    }
  }

  Widget sectionTitle(String text) => Padding(
    padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
    child: Text(text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget arrowItem(String title, {Function()? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("설정"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 프로필 박스
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.teal,
                    child: Text(
                      "M",
                      style: TextStyle(fontSize: 26, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Move온 사용자",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("qr",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),

            Divider(),

            // 계정 관리
            sectionTitle("계정 관리"),

            arrowItem("프로필 수정",
                onTap: () => Navigator.pushNamed(context, "/profile")),
            arrowItem("비밀번호 변경",
                onTap: () => Navigator.pushNamed(context, "/updatepwd")),
            arrowItem("개인정보 관리"),

            Divider(),

            // 로그아웃
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: OutlinedButton(
                onPressed: logout,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  side: BorderSide(color: Colors.grey),
                ),
                child: Text("로그아웃"),
              ),
            ),

            // 회원탈퇴
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: signout,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  side: BorderSide(color: Colors.red),
                ),
                child: Text("회원탈퇴",
                    style: TextStyle(color: Colors.red, fontSize: 15)),
              ),
            ),

            SizedBox(height: 20),

            Text(
              "Move온은 개인정보를 안전하게 보호합니다",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
