import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/screens/onboarding/OnboardingAddress.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

class OnboardingStart extends StatefulWidget {
  const OnboardingStart({super.key});

  @override
  StateOnboardingStart createState() => StateOnboardingStart();
}

class StateOnboardingStart extends State<OnboardingStart> {
  TextEditingController midCont = TextEditingController();
  TextEditingController mpwdCont = TextEditingController();

  Future<bool> login() async {
    try {
      final obj = {"mid": midCont.text, "mpwd": mpwdCont.text};

      final response = await dio.post(
        "http://10.0.2.2:8080/api/member/login",
        data: obj,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      final data = response.data;

      if (data != null && data['token'] != null) {
        final sp = await SharedPreferences.getInstance();

        await sp.setString('logintoken', data['token']);
        await sp.remove('guestToken');

        await sp.setString('mname', data['member']['mname']);
        await sp.setString('wishlist', data['member']['wishlist'] ?? "");

        return true;
      }
    } catch (e) {
      print("로그인 실패 $e");
    }
    return false;
  }

  void guest() async {
    try {
      final response = await dio.post("http://10.0.2.2:8080/api/guest/save");
      final data = response.data;

      final sp = await SharedPreferences.getInstance();
      sp.setString("guestToken", data["token"]);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OnboardingAddress()),
      );
    } catch (e) {
      print("게스트 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF33C9C9);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 로고
                Text(
                  "mOveOn",
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 6),
                Text(
                  "새로운 시작, 안전한 정착",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
                SizedBox(height: 40),

                // 카드 형태 로그인 입력 박스
                Container(
                  padding: EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: midCont,
                        decoration: InputDecoration(
                          labelText: "아이디",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: mpwdCont,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "비밀번호",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 20),

                      // 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            bool ok = await login();
                            if (!mounted) return;

                            final sp = await SharedPreferences.getInstance();
                            String? wishlist = sp.getString('wishlist');

                            if (ok) {
                              if (wishlist == null || wishlist.isEmpty) {
                                Navigator.pushReplacementNamed(
                                    context, "/onboardingCategory");
                              } else {
                                Navigator.pushReplacementNamed(context, "/");
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("로그인 정보를 확인해주세요.")));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "로그인",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                SizedBox(height: 25),

                // 회원/비번 찾기 링크
                TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, "/findid"),
                    child: Text("아이디 찾기",
                        style: TextStyle(color: Colors.white70))),

                TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, "/findpwd"),
                    child: Text("비밀번호 찾기",
                        style: TextStyle(color: Colors.white70))),

                TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, "/signup"),
                    child: Text("회원가입",
                        style:
                        TextStyle(color: Colors.white, fontSize: 16))),

                SizedBox(height: 20),

                // 게스트 버튼
                OutlinedButton(
                  onPressed: guest,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white, width: 1.5),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "게스트로 시작하기",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
