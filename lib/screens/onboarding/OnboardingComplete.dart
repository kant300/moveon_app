import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio=Dio();
// 1. 위젯클래스
class OnboardingComplete extends StatefulWidget{
  // 이전 단계에서 설정된 주소를 받을 수 있도록 인수를 추가했습니다.
  // 이 예시에서는 임시로 하드코딩된 값을 사용합니다.


@override
  State<OnboardingComplete> createState() => OnboardingCompleteState();
}
// 2. 상태클래스(SingleTickerProviderStateMixin 추가)
class OnboardingCompleteState extends State<OnboardingComplete>with SingleTickerProviderStateMixin{


  String address = "";

  // 앱의 메인 청록색 정의
  final Color _mainTealColor = const Color(0xFF3DE0D2);
  // 카드 배경색 정의: 메인 청록색보다 밝은 톤 (Light Cyan 계열)
  final Color _cardBgColor = const Color(0xFFE0FFFF); // #E0FFFF
  // 텍스트/아이콘 색상: 흰색
  final Color _textColor = Colors.white;
  // 카드 내부 텍스트 색상: 회색
  final Color _cardTextColor = Colors.grey.shade700; // 어두운 회색

  // 🌟 애니메이션 컨트롤러 추가 🌟
  late AnimationController _animationController;
  late Animation<double> _animation;

  // 핵심 정보 목록
  final List<Map<String, dynamic>> _coreFeatures = const [
    {
      'title': '안전 정보 활성화',
      'subtitle': 'CCTV, 성범죄자 위치 등 실시간 확인 가능',
      'icon': Icons.verified_user,
      'iconColor': Color(0xFFDC3545),// 빨강
      'iconBorderColor':Color(0xFFDC3545) ,
    },
    {
      'title': '정착 루트맵 준비 완료',
      'subtitle': '주변 공공 데이'
          '터를 지도에서 확인하세요.',
      'icon': Icons.map,
      'iconColor': Color(0xFF007BFF),// 파랑 (정보/지도 관련)
      'iconBorderColor': Color(0xFF007BFF),
    },
    {
      'title': '커뮤니티 입장',
      'subtitle': '이웃과 연결되어 정보를 나눠보세요.',
      'icon': Icons.people,
      'iconColor': Color(0xFFFFC107),// 주황색 (커뮤니티 관련)
      'iconBorderColor': Color(0xFFFFC107),
    },
  ];


  @override
  void initState() {
    super.initState();
    guesttoken(); // 불러오기 정보
    // 🌟 애니메이션 컨트롤러 초기화 🌟
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000), // 1초 동안 애니메이션
    )..repeat(reverse: true); // 계속 반복 (왔다갔다)
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose(); // 컨트롤러 해제
    super.dispose();
  }


  void guesttoken() async{
      final localsave = await SharedPreferences.getInstance();
      final token = localsave.getString("guestToken");

      if(token == null) return;
    try{
      final response = await dio.get("http://10.0.2.2:8080/api/guest/address",
      options: Options(headers: {"Authorization" : "Bearer $token"},) );
      final data = await response.data;
      print(data);

      setState(() {
        address = "${data['gaddress1']} ${data['gaddress2']} ${data['gaddress3']}";
      });

    }catch(e) { print(e); }
  }

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
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
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
                  const SizedBox(height: 70),

                  // --- 2. Central Image/Icon ---
                  // 이미지 삽입
                  Container(
                    alignment: Alignment.center,  // 명시적 가운데 정렬
                    child: FadeTransition(
                      opacity: _animation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _cardBgColor.withOpacity(0.5), // 메인색보다 밝은 톤의 50% 투명도
                          shape: BoxShape.circle,
                          border: Border.all(color: _textColor, width: 3), // 흰색 테두리
                        ),
                        child: Icon(Icons.auto_awesome_outlined, size: 70, color: _textColor), // 🌟 아이콘 색상 흰색 🌟
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- 3. Main Title ---
                  Text(
                    "이제 안전한 정착여정을 시작할까요?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. OnboardingAddress에서 설정한 주소를 표시
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text( address.isEmpty ? "설정된 주소가 없음" : address,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // --- 5. Core Features Cards ---
                  ..._coreFeatures.map((feature) => _buildFeatureCard(
                    title: feature['title'] as String,
                    subtitle: feature['subtitle'] as String,
                    icon: feature['icon'] as IconData,
                    iconColor: feature['iconColor'] as Color,
                    iconBorderColor: feature['iconBorderColor'] as Color, // 🌟 아이콘 테두리 색상 전달 🌟
                  )).toList(),
                ],
              ),
            ),

            const Spacer(),

            // --- 6. Bottom Buttons ---
            Padding(
              padding: const EdgeInsets.only(bottom: 50, top: 20) + const EdgeInsets.symmetric(horizontal: 24.0),
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
                          MaterialPageRoute(builder: (context) => Main()), // Main()으로 가정
                              (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.yellow, // 흰색 배경
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
          ],
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
    required Color iconBorderColor, // 🌟 아이콘 테두리 색상 인수로 받기 🌟
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
                border: Border.all(color: iconBorderColor, width: 2),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _cardTextColor, // 🌟 텍스트 색상 메인 청록색 🌟
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: _cardTextColor.withOpacity(0.8), // 🌟 텍스트 색상 메인 청록색 (살짝 투명) 🌟
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