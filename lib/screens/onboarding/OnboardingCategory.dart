import 'package:flutter/material.dart';
import 'package:moveon_app/screens/onboarding/OnboardingComplete.dart';

// 1. 위젯클래스
class OnboardingCategory extends StatefulWidget {
  const OnboardingCategory({super.key});

  // 2. 상태클래스
  @override
 State<OnboardingCategory> createState() => OnboardingCategoryState();
}

class OnboardingCategoryState extends State<OnboardingCategory> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("카테고리 선택"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {// "다음" 버튼 클릭 시 다음 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OnboardingComplete(), // 설정완료 페이지로 이동
              ),
            );
          },
          child: const Text("다음 단계"),
        ),
      ),
    );
  }
}
