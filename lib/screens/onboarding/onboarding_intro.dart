import 'package:flutter/material.dart';
import 'onboarding_address.dart'; // 다음 페이지 (OnboardingAddressScreen이 정의되어 있다고 가정)

class OnboardingIntroScreen extends StatelessWidget {
  const OnboardingIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF33C9C9); // 청록색 계열

    return Scaffold(
      body: Container(
        color: primaryColor,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 상단 로고 및 문구
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'mOveOn',
                        style: TextStyle(
                          fontSize: 48,
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
                    ],
                  ),
                ),
              ),

              // 하단 버튼 영역
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 40.0),
                // 💡 Center 대신 Row를 사용하고, MainAxisAlignment.center로 중앙 정렬합니다.
                // Row는 자식에게 필요한 만큼만 너비를 할당하므로, ConstrainedBox의 제약이 명확하게 적용됩니다.
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔹 ConstrainedBox를 사용하여 버튼의 최대 너비를 300으로 제한합니다.
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 100), // 최대 너비 300 제한
                      child: SizedBox(
                        height: 56, // 🔹 버튼 세로 고정
                        // ConstrainedBox와 Row 안에 있는 경우, 이 버튼은 Row의 제약 조건을 받습니다.
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0, // 그림자 제거
                            // Row 내부에서 ConstrainedBox의 너비(300)를 꽉 채우도록 설정
                            minimumSize: const Size(300, 56),
                          ),
                          onPressed: () {
                            // 클래스 이름을 OnboardingAddressScreen으로 통일했습니다.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnboardingAddressScreen(),
                              ),
                            );
                          },
                          child: const Text(
                              '다음',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                          ),
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