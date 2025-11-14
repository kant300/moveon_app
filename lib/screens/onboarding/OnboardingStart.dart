import 'package:flutter/material.dart';
import 'package:moveon_app/screens/onboarding/OnboardingAddress.dart';


// 온보딩 첫 화면 위젯 (앱 시작 시 가장 먼저 보이는 화면)
class OnboardingStart extends StatelessWidget{
  const OnboardingStart( {super.key});

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
                    children: const [
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
                    ],
                  ),
                ),
              ),

              //하단 버튼 영역
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 40.0),
                // 💡 Center 대신 Row를 사용하고, MainAxisAlignment.center로 중앙 정렬합니다.
                // Row는 자식에게 필요한 만큼만 너비를 할당하므로, ConstrainedBox의 제약이 명확하게 적용됩니다.
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔹 ConstrainedBox를 사용하여 버튼의 최대 너비를 300으로 제한합니다.
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300), // 최대 너비 300 제한
                      child: SizedBox(
                        height: 56, // 🔹 버튼 세로 고정
                        // ConstrainedBox와 Row 안에 있는 경우, 이 버튼은 Row의 제약 조건을 받습니다.
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow, // 버튼 배경색 흰색
                            foregroundColor: primaryColor, // 텍스트/아이콘색
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                            ),
                            elevation: 0, // 그림자 제거
                            // Row 내부에서 ConstrainedBox의 너비(300)를 꽉 채우도록 설정
                            minimumSize: const Size(200, 56),
                          ),
                          onPressed: () {
                            // "다음" 버튼 클릭 시 다음 페이지로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnboardingAddress(), // 주소 입력 페이지로 이동
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