import 'package:flutter/material.dart';
import 'package:moveon_app/main.dart';


// 1. 위젯클래스
class OnboardingComplete extends StatefulWidget{
  // 이전 단계에서 설정된 주소를 받을 수 있도록 인수를 추가했습니다.
  // 이 예시에서는 임시로 하드코딩된 값을 사용합니다.
  final String selectedAddress;

  const OnboardingComplete( {super.key, this.selectedAddress ="인천시 연수구 동춘동" });

// 2. 상태클래스
@override
  State<OnboardingComplete> createState() => OnboardingCompleteState();
}

class OnboardingCompleteState extends State<OnboardingComplete>{

  // 앱의 메인 청록색 정의
  final Color _mainTealColor = const Color(0xFF3DE0D2);
  // 카드 배경색 정의: 메인 청록색보다 밝은 톤 (Light Cyan 계열)
  final Color _lightTealColor = const Color(0xFFE0FFFF); // #E0FFFF
  // 텍스트/아이콘 색상: 흰색
  final Color _textColor = Colors.white;

  // 핵심 정보 목록
  final List<Map<String, dynamic>> _coreFeatures = [
    {
      'title': '안전 정보 활성화',
      'subtitle': 'CCTV, 성범죄자 위치 등 실시간 확인 가능',
      'icon': Icons.verified_user,
      'color': const Color(0xFF28A745), // 녹색 (안전 관련)
    },
    {
      'title': '정착 루트맵 준비 완료',
      'subtitle': '주변 공공 데이터를 지도에서 확인하세요.',
      'icon': Icons.map,
      'color': const Color(0xFF007BFF), // 보라색 (정보/지도 관련)
    },
    {
      'title': '커뮤니티 입장',
      'subtitle': '이웃과 연결되어 정보를 나눠보세요.',
      'icon': Icons.people,
      'color': const Color(0xFFFFC107), // 주황색 (커뮤니티 관련)
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌟 전체 배경색을 메인 테마색상으로 변경 🌟
      backgroundColor: _mainTealColor,
      appBar: AppBar(
        // 뒤로가기 버튼 제거 (완료 화면이므로)
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent, // 🌟 투명하게 설정 🌟
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0 ) ,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Progress Bar (3단계 완료) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _colorBar(_textColor),   // 진한 청록 1단계 (완료)
                const SizedBox(width: 24),
                _colorBar(_textColor),   // 연한 민트 2단계 (완료)
                const SizedBox(width: 24),
                _colorBar(_textColor),   // 더 연한 민트 3단계 (완료)
              ],
            ),
            const SizedBox(height: 32),

            // --- 2. Central Image/Icon ---
            // 이미지 삽입
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _cardBgColor.withOpacity(0.5), // 메인색보다 밝은 톤의 50% 투명도
                shape: BoxShape.circle,
                border: Border.all(color: _textColor, width: 3), // 흰색 테두리
              ),
              child: Icon(Icons.check_circle_outline, size: 60, color: _textColor), // 🌟 아이콘 색상 흰색 🌟
            ),
            const SizedBox(height: 32),

            // --- 3. Main Title ---
            const Text(
              "이제 안전한 정착여정을 시작합니다.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 24),

            // OnboardingAddress에서 설정한 주소를 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.selectedAddress, // OnboardingAddress에서 가져온 주소
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _cardBgColor, // 🌟 메인색보다 밝은 톤의 배경 🌟
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "내가 설정한 위치",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _mainTealColor, // 청록색 텍스트
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 5. Core Features Cards ---
            ..._coreFeatures.map((feature) => _buildFeatureCard(
              title: feature['title'] as String,
              subtitle: feature['subtitle'] as String,
              icon: feature['icon'] as IconData,
              iconColor: feature['color'],
            )).toList(),

            const Spacer(),

            // --- 6. Bottom Buttons ---
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 16),
              child: Row(
                children: [
                  // 🌟 "이전" 버튼 (Flex 2) 🌟
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // 이전 화면으로 돌아가기
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: BorderSide(color: _textColor, width: 2), // 흰색 테두리
                        foregroundColor: _textColor, // 흰색 텍스트
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("이전", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 🌟 "시작하기" 버튼 (Flex 3, 1.5배 크기) 🌟
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: () {
                        // 메인 페이지로 이동
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Main()), // Main()으로 가정
                              (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: _textColor, // 흰색 배경
                        foregroundColor: _mainTealColor, // 청록색 텍스트
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("시작하기", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }







  // Progress Bar 위젯
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

  // 핵심 기능 카드 위젯
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBgColor, // 🌟 카드 배경색 변경 🌟
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘 영역 (원형 배경)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _mainTealColor, // 🌟 아이콘 배경색을 메인 청록색으로 변경 🌟
                shape: BoxShape.circle,
                //border: Border.all(color: iconColor, width: 2),
              ),
              child: Icon(icon, color: _textColor, size: 24),
            ),
            const SizedBox(width: 16),
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _mainTealColor, // 🌟 텍스트 색상 메인 청록색 🌟
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _mainTealColor.withOpacity(0.8), // 🌟 텍스트 색상 메인 청록색 (살짝 투명) 🌟
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}