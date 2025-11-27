import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

class OnboardingComplete extends StatefulWidget {
  @override
  State<OnboardingComplete> createState() => OnboardingCompleteState();
}

class OnboardingCompleteState extends State<OnboardingComplete>
    with SingleTickerProviderStateMixin {
  String address = "";
  String wishlists = "";

  final Color _mainTealColor = const Color(0xFF3DE0D2);
  final Color _cardBgColor = const Color(0xFFE0FFFF);
  final Color _textColor = Colors.white;
  final Color _cardTextColor = Colors.grey;

  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> _coreFeatures = const [
    {
      'title': '안전 정보 활성화',
      'subtitle': 'CCTV, 성범죄자 위치 등 실시간 확인 가능',
      'icon': Icons.verified_user,
      'iconColor': Color(0xFFDC3545),
      'iconBorderColor': Color(0xFFDC3545),
    },
    {
      'title': '정착 루트맵 준비 완료',
      'subtitle': '주변 공공 데이터를 지도에서 확인하세요.',
      'icon': Icons.map,
      'iconColor': Color(0xFF007BFF),
      'iconBorderColor': Color(0xFF007BFF),
    },
    {
      'title': '커뮤니티 입장',
      'subtitle': '이웃과 연결되어 정보를 나눠보세요.',
      'icon': Icons.people,
      'iconColor': Color(0xFFFFC107),
      'iconBorderColor': Color(0xFFFFC107),
    },
  ];

  @override
  void initState() {
    super.initState();
    guesttoken();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void guesttoken() async {
    final localsave = await SharedPreferences.getInstance();
    final token = localsave.getString("guestToken");
    if (token == null) return;

    try {
      final response = await dio.get(
        "http://10.95.125.46:8080/api/guest/address",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final data = response.data;
      setState(() {
        address =
            "${data['gaddress1'] ?? ''} ${data['gaddress2'] ?? ''} ${data['gaddress3'] ?? ''}"
                .trim();
        wishlists = data['wishlist'] ?? '';
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mainTealColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // ⭐ 스크롤 가능하게 만들기 → 오버플로우 해결
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _colorBar(_textColor),
                  SizedBox(width: 24),
                  _colorBar(_textColor),
                  SizedBox(width: 24),
                  _colorBar(_textColor),
                ],
              ),

              SizedBox(height: 70),

              // Ani icon
              Center(
                child: FadeTransition(
                  opacity: _animation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _cardBgColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: _textColor, width: 3),
                    ),
                    child: Icon(Icons.auto_awesome_outlined,
                        size: 70, color: _textColor),
                  ),
                ),
              ),

              SizedBox(height: 40),

              Text(
                "이제 안전한 정착여정을 시작할까요?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 24),

              // Address
              Text(
                address.isEmpty ? "설정된 주소가 없음" : address,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 40),

              // Feature cards
              ..._coreFeatures.map((f) => _buildFeatureCard(
                title: f['title'],
                subtitle: f['subtitle'],
                icon: f['icon'],
                iconColor: f['iconColor'],
                iconBorderColor: f['iconBorderColor'],
              )),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ⭐ 아래 버튼은 bottomNavigationBar 로 분리 → overflow 방지
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 20),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    side: BorderSide(color: _textColor, width: 2),
                    foregroundColor: _textColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("이전",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/",
                        arguments: true);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.yellow,
                    foregroundColor: _mainTealColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("시작하기",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBorderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _mainTealColor,
                shape: BoxShape.circle,
                border: Border.all(color: iconBorderColor, width: 2),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _cardTextColor)),
                  SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13,
                          color: _cardTextColor.withOpacity(0.8))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
