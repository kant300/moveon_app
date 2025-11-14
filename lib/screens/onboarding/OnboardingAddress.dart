import 'package:flutter/material.dart';

class OnboardingAddress extends StatefulWidget {
  const OnboardingAddress({super.key});

  @override
  OnboardingAddressState createState() => OnboardingAddressState();
}

class OnboardingAddressState extends State<OnboardingAddress> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("주소 확인"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 주소 입력 완료 → 카테고리 선택 페이지로 이동 (추후 연결)
          },
          child: const Text("다음 단계"),
        ),
      ),
    );
  }
}
