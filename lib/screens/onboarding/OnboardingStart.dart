import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/main.dart';
import 'package:moveon_app/screens/onboarding/OnboardingAddress.dart';
import 'package:moveon_app/member/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();
// 온보딩 첫 화면 위젯 (앱 시작 시 가장 먼저 보이는 화면)
class OnboardingStart extends StatefulWidget {
  const OnboardingStart({super.key});

  @override
  StateOnboardingStart createState() => StateOnboardingStart();
}
class StateOnboardingStart extends State<OnboardingStart>{


  dynamic test = {};


  // 로그인
  TextEditingController midCont = TextEditingController(); // 아이디
  TextEditingController mpwdCont = TextEditingController(); // 비밀번호

  // ✅ 수정: 비동기 함수이므로 반환 타입을 Future<void>로 변경했습니다.
  Future<void> login() async{
    try {
      final obj = {
        "mid": midCont.text,
        "mpwd": mpwdCont.text,
      };
      final response = await dio.post(
        "http://10.164.103.46:8080/api/member/login", data: obj,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      final data = await response.data;
      print(data);
      print(obj);
      if (data != null) {
        setState(() {
          test = data['member'];
        });

        final localsave = await SharedPreferences.getInstance();
        if(data['token'] != null ){
          await localsave.setString('logintoken', data['token'] );
          print(localsave);
          print("토큰 저장 : ${data['token']}");
        }
        await localsave.setString('mname', data['member']['mname']);

        print("로그인 성공");

        Navigator.pop(context, {
          'mname': data['member']['mname'], // 이름 전달
        });

      }
    }catch(e) { print("로그인 실패 $e") ; }
  }
  
  void guest() async{
    try{
      final response = await dio.post("http://10.164.103.46:8080/api/guest/save");
      final data = await response.data;
      final token = data["token"];

      final localsave = await SharedPreferences.getInstance();
        await localsave.setString('guestToken', token );
        print(localsave);
        print("토큰 확인 : ${data['token'] }");
        Navigator.push(context, MaterialPageRoute(builder: (_) => OnboardingAddress() ),
        );
      }catch(e) { print(e); }
    }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF33C9C9); //  메인 테마색상 (민트/청록색)
    return Scaffold(
      body: Container(
        color: primaryColor, // 전체 배경색 설정
        child: SafeArea( // 노치/상단바 영역 침범 방지
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 상단-하단 간격을 최대화
            children: [
              // 상단 로고 및 문구
              Expanded(
                child: Center( // 중앙정렬
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 배치
                    children: [
                      Text( // 앱 로고 텍스트
                        'mOveOn',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '새로운 시작, 안전한 정착',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),

                      TextField( controller: midCont  ),
                      TextField( controller: mpwdCont  ),

                      OutlinedButton(
                          onPressed: () async {
                            // 1. login() 함수가 Future<void>를 반환하도록 정의되어야 합니다.
                            await login();
                            // 2. 비동기 작업 후, 위젯이 마운트된 상태(mounted)일 때만 화면 이동
                            if (mounted) {
                              Navigator.pushReplacementNamed(context, "/main");
                            }
                          },
                          child: Text("로그인")
                      ),
                      TextButton(onPressed: (){ Navigator.pushReplacementNamed(context, "/findid"); } , child: Text("아이디찾기"), ),
                      TextButton(onPressed: (){ Navigator.pushReplacementNamed(context, "/findpwd"); } , child: Text("비밀번호찾기"), ),
                      TextButton(onPressed: (){Navigator.pushReplacementNamed(context, "/signup"); }, child: Text("회원가입 페이지로 이동"),),
                      TextButton(onPressed: guest , child: Text("Guest"),),
                    ],
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