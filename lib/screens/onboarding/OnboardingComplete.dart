import 'package:flutter/material.dart';
import 'package:moveon_app/main.dart';


// 1. 위젯클래스
class OnboardingComplete extends StatefulWidget{
  const OnboardingComplete( {super.key});

// 2. 상태클래스
@override
  State<OnboardingComplete> createState() => OnboardingCompleteState();
}

class OnboardingCompleteState extends State<OnboardingComplete>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("설정 완료"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () { // "다음" 버튼 클릭 시 다음 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Main(), // 메인 홈페이지로 이동
                ),
              );
            },
          child: const Text("시작하기"),
        ),
      ),
    );
  }
}