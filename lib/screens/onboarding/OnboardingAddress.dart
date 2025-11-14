import 'package:flutter/material.dart';
import 'package:moveon_app/screens/onboarding/OnboardingCategory.dart';

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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorBar(const Color(0xFF3DE0D2)),   // 진한 청록
              const SizedBox(width: 24),
              _colorBar(const Color(0xFF7FFFD4)),   // 연한 민트
              const SizedBox(width: 24),
              _colorBar(const Color(0xFFC5F6F6)),   // 더 연한 민트
           ],
          ),
          Text("어디로 이사 오셨나요?"),
          Text("새로운 동네 정보를 알려 드릴게요"),

          ElevatedButton(
            onPressed: () {// "다음" 버튼 클릭 시 다음 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OnboardingCategory(), // 카테고리선택 페이지로 이동
                ),
              );
            },
            child: const Text("다음 단계"),
          ),
        ],
      ),
    );
  }
  Widget _colorBar(Color color) {
    return Container(
      width: 60,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
