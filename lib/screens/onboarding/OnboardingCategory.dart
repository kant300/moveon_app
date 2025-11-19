import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moveon_app/screens/onboarding/OnboardingComplete.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 카테고리 데이터 모델
class CategoryItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isRequired;

  CategoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isRequired = false,
  });
}

final dio = Dio();

// 1. 위젯클래스
class OnboardingCategory extends StatefulWidget {
  const OnboardingCategory({super.key});

  // 2. 상태클래스
  @override
  State<OnboardingCategory> createState() => OnboardingCategoryState();
}

class OnboardingCategoryState extends State<OnboardingCategory> {
  // 1. 카테고리 목록 정의
  final List<CategoryItem> _categories = [
    CategoryItem(
      id: 'safety',
      title: '안전',
      subtitle: '치안, 안전시설',
      isRequired: true,
    ),
    CategoryItem(id: 'transport', title: '교통', subtitle: '지하철, 버스정보'),
    CategoryItem(id: 'life', title: '생활', subtitle: '병원,약국,편의점'),
    CategoryItem(id: 'community', title: '커뮤니티', subtitle: '소분모임,이웃소통'),
  ];

  // 2. 선택 상태 관리 (Key: Category ID, Value: isSelected)
  // 'safety'는 필수로 선택된 상태로 시작합니다.
  Map<String, bool> _categorySelections = {
    'safety': true,
    'transport': false,
    'life': false,
    'community': false,
  };

  // 3. 선택된 항목 수를 계산하는 Getter
  int get _selectedCount =>
      _categorySelections.values.where((selected) => selected).length;

  // 4. 카드 클릭 이벤트 처리 함수
  void _toggleSelection(String categoryId) {
    // 안전(필수항목)은 선택 해제 불가
    if (categoryId == 'safety') return;

    setState(() {
      // 현재 상태의 반대값으로 토글
      _categorySelections[categoryId] =
          !(_categorySelections[categoryId] ?? false);
    });
  }

  // 카테고리 ID에 따른 색상 정의
  Color _getCategoryColor(String id) {
    switch (id) {
      case 'safety':
        // 옵션 1: 강렬한 레드
        return const Color(0xFFDC3545);
      case 'transport':
        // 옵션 1: 선명한 블루
        return const Color(0xFF007BFF);
      case 'life':
        // 옵션 1: 활기찬 그린
        return const Color(0xFF28A745);
      case 'community':
        // 옵션 1: 밝은 앰버 옐로우
        return const Color(0xFFFFC107);
      default:
        return Colors.grey.shade500;
    }
  }

  void guest() async {
    final localsave = await SharedPreferences.getInstance();
    final token = localsave.getString("guestToken");
    try {
      List<String> selectgory = _categories
        .where((go) => _categorySelections[go.id] == true)
        .map((go) => go.id)
        .toList();

      String wishstr = selectgory.join(",");

      final obj = {
        "wishlist": wishstr,
      };
      final response = await dio.post(
        "http://10.164.103.46:8080/api/guest/wishlist",
        data: obj,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      final data = await response.data;
      print(data);
    } catch (e) {
      print(e);
    }
  }

  // 5. Build 메서드
  @override
  Widget build(BuildContext context) {
    // 화면 너비를 가져와 카드 크기를 계산합니다.
    final double screenWidth = MediaQuery.of(context).size.width;
    // 전체 패딩 24 * 2 = 48
    // 카드 사이 여백 20
    // 카드 두 개가 차지하는 너비 = (screenWidth - 48 - 20) / 2
    final double calculatedCardWidth = (screenWidth - (24 * 2) - 20) / 2;

    // 🌟 카드 높이 조정: cardHorizontalSpace를 기준으로 약간 더 높게 설정 🌟
    // 예시: 가로 길이의 1.2배 정도로 설정하여 세로로 살짝 길게 만듭니다.
    final double calculatedCardHeight = calculatedCardWidth * 1.2;

    return Scaffold(
      appBar: AppBar(
        // AppBar의 기본 그림자 제거 (이미지와 일치시키기 위해)
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Progress Bar ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _colorBar(const Color(0xFF3DE0D2)), // 진한 청록 1단계 (완료)
                const SizedBox(width: 24),
                _colorBar(const Color(0xFF3DE0D2)), // 연한 민트 2단계 (현재)
                const SizedBox(width: 24),
                _colorBar(const Color(0xFFC5F6F6)), // 더 연한 민트 3단계 (미완료)
              ],
            ),
            const SizedBox(height: 32),

            // --- 2. Title & Subtitle ---
            const Text(
              "어떤 정보가 필요하신가요?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "관심있은 정보를 모두 선택해주세요",
              style: TextStyle(fontSize: 17, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // --- 3. Category Cards (2x2 Layout) ---
            Column(
              children: [
                // 1행: 안전, 교통
                Row(
                  children: [
                    // 🌟 계산된 지역 변수를 인수로 전달 🌟
                    _buildCategoryCard(
                      _categories[0],
                      calculatedCardWidth,
                      calculatedCardHeight,
                    ),
                    const SizedBox(width: 20),
                    _buildCategoryCard(
                      _categories[1],
                      calculatedCardWidth,
                      calculatedCardHeight,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // 2행: 생활, 커뮤니티
                Row(
                  children: [
                    _buildCategoryCard(
                      _categories[2],
                      calculatedCardWidth,
                      calculatedCardHeight,
                    ),
                    const SizedBox(width: 20),
                    _buildCategoryCard(
                      _categories[3],
                      calculatedCardWidth,
                      calculatedCardHeight,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "선택한 카테고리의 주요 서비스가 즐겨찾기에 자동 추가됩니다.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey, // 흰색에 투명도 적용
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24), // 다음 요소와의 간격 조정
            // 🌟 Spacer를 사용하여 아래쪽 요소들을 하단으로 밀어냅니다. 🌟
            const Spacer(),

            // --- 4. Bottom Selection Count and Buttons ---
            Padding(
              padding: const EdgeInsets.only(bottom: 50, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 선택된 항목 수
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "선택된 항목 : $_selectedCount개",
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // 이전 버튼 (흰색/회색)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: 이전 페이지로 돌아가는 로직 (보통 Navigator.pop)
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "이전",
                            style: TextStyle(color: Colors.grey, fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 다음 버튼 (활성화/비활성화)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedCount > 0
                              ? () {
                                  guest();
                                  // "다음" 버튼 클릭 시 다음 페이지로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OnboardingComplete(), // 설정완료 페이지로 이동
                                    ),
                                  );
                                }
                              : null, // 선택된 항목이 없으면 버튼 비활성화
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: _selectedCount > 0
                                ? const Color(0xFF3DE0D2)
                                : Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "다음",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Widgets ---

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

  // Category Card 위젯
  Widget _buildCategoryCard(
    CategoryItem item,
    double cardWidth,
    double cardHeight,
  ) {
    final bool isSelected = _categorySelections[item.id] ?? false;

    // 선택 여부에 따른 배경색 및 글자색 설정
    final Color selectedBgColor = _getCategoryColor(item.id);
    final Color selectedTextColor = Colors.white;
    final Color unselectedBgColor = Colors.white;
    final Color unselectedTextColor = Colors.black;

    final Color backgroundColor = isSelected
        ? selectedBgColor
        : unselectedBgColor;
    final Color titleColor = isSelected
        ? selectedTextColor
        : unselectedTextColor;
    final Color subtitleColor = isSelected
        ? selectedTextColor.withOpacity(0.7)
        : Colors.grey.shade600;

    return SizedBox(
      width: cardWidth,
      height: cardHeight, // 🌟 인수로 받은 cardHeight 적용 🌟
      child: InkWell(
        onTap: () => _toggleSelection(item.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? selectedBgColor : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedBgColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 아이콘 및 체크마크
              Stack(
                children: [
                  // 아이콘 (임시 아이콘 사용)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(item.id), // 카테고리별 아이콘 가져오기
                      color: isSelected ? Colors.white : Colors.black,
                      size: 28,
                    ),
                  ),
                  // 선택/필수 체크마크
                  if (isSelected)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : selectedBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check, // 필수는 닫기 대신 체크로 변경 (이미지 반영)
                          color: item.isRequired
                              ? Colors.red.shade600
                              : selectedBgColor,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),

              // 제목 및 부제목
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                  if (item.isRequired)
                    Text(
                      "필수 선택항목",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? selectedTextColor
                            : Colors.red.shade600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 카테고리 ID에 따른 적절한 아이콘을 반환하는 헬퍼 함수
  IconData _getIcon(String id) {
    switch (id) {
      case 'safety':
        return Icons.security; // 안전
      case 'transport':
        return Icons.directions_bus; // 교통
      case 'life':
        return Icons.local_convenience_store; // 생활
      case 'community':
        return Icons.groups; // 커뮤니티
      default:
        return Icons.category;
    }
  }
}
