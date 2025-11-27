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

class OnboardingCategory extends StatefulWidget {
  const OnboardingCategory({super.key});

  @override
  State<OnboardingCategory> createState() => OnboardingCategoryState();
}

class OnboardingCategoryState extends State<OnboardingCategory> {
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

  final Map<String, List<String>> cgorymap = {
    "safety": ["성범죄자", "민간구급차", "비상급수시설", "대피소", "공중화장실", "CCTV"],
    "transport": ["지하철", "버스정류장", "전동휠체어 충전소", "공용주차장"],
    "life": ["공과금 정산", "전입신고", "의류수거함", "쓰레기 배출", "폐가전 수거", "관공서", "심야약국/병원"],
    "community": ["소분모임", "지역행사", "중고장터", "동네후기", "구인/구직"],
  };

  Map<String, bool> _categorySelections = {
    'safety': true,
    'transport': false,
    'life': false,
    'community': false,
  };

  int get _selectedCount =>
      _categorySelections.values.where((selected) => selected).length;

  void _toggleSelection(String categoryId) {
    if (categoryId == 'safety') return;

    setState(() {
      _categorySelections[categoryId] =
      !(_categorySelections[categoryId] ?? false);
    });
  }

  Color _getCategoryColor(String id) {
    switch (id) {
      case 'safety':
        return const Color(0xFFDC3545);
      case 'transport':
        return const Color(0xFF007BFF);
      case 'life':
        return const Color(0xFF28A745);
      case 'community':
        return const Color(0xFFFFC107);
      default:
        return Colors.grey.shade500;
    }
  }

  Future<void> savewishlist() async {
    final localsave = await SharedPreferences.getInstance();
    final logintoken = localsave.getString("logintoken");
    final guesttoken = localsave.getString("guestToken");

    List<String> selectgory = _categories
        .where((go) => _categorySelections[go.id] == true)
        .map((go) => go.id)
        .toList();

    List<String> cgory = [];
    for (final id in selectgory) {
      cgory.addAll(cgorymap[id] ?? []);
    }

    String wishstr = cgory.join(",");

    final obj = {"wishlist": wishstr};

    try {
      if (logintoken != null) {
        final response = await dio.put(
          "http://10.95.125.46:8080/api/member/wishlist",
          data: obj,
          options: Options(headers: {"Authorization": "Bearer $logintoken"}),
        );
        return;
      }

      if (guesttoken != null) {
        final response = await dio.put(
          "http://10.95.125.46:8080/api/guest/wishlist",
          data: obj,
          options: Options(headers: {"Authorization": "Bearer $guesttoken"}),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double calculatedCardWidth = (screenWidth - (24 * 2) - 20) / 2;
    final double calculatedCardHeight = calculatedCardWidth * 1.2;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _colorBar(const Color(0xFF3DE0D2)),
                  SizedBox(width: 24),
                  _colorBar(const Color(0xFF3DE0D2)),
                  SizedBox(width: 24),
                  _colorBar(const Color(0xFFC5F6F6)),
                ],
              ),
              SizedBox(height: 32),

              Text(
                "어떤 정보가 필요하신가요?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "관심있은 정보를 모두 선택해주세요",
                style: TextStyle(fontSize: 17, color: Colors.grey),
              ),
              SizedBox(height: 30),

              // Card Grid
              Column(
                children: [
                  Row(
                    children: [
                      _buildCategoryCard(
                          _categories[0], calculatedCardWidth, calculatedCardHeight),
                      SizedBox(width: 20),
                      _buildCategoryCard(
                          _categories[1], calculatedCardWidth, calculatedCardHeight),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      _buildCategoryCard(
                          _categories[2], calculatedCardWidth, calculatedCardHeight),
                      SizedBox(width: 20),
                      _buildCategoryCard(
                          _categories[3], calculatedCardWidth, calculatedCardHeight),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 30),

              Text(
                "선택한 카테고리의 주요 서비스가 즐겨찾기에 자동 추가됩니다.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              SizedBox(height: 40),

              // Bottom Section
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  children: [
                    Text(
                      "선택된 항목 : $_selectedCount개",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _selectedCount > 0
                          ? () async {
                        await savewishlist();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OnboardingComplete(),
                          ),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: _selectedCount > 0
                            ? Color(0xFF3DE0D2)
                            : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text("다음", style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              )
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

  Widget _buildCategoryCard(
      CategoryItem item, double cardWidth, double cardHeight) {
    final bool isSelected = _categorySelections[item.id] ?? false;

    final Color backgroundColor =
    isSelected ? _getCategoryColor(item.id) : Colors.white;
    final Color titleColor = isSelected ? Colors.white : Colors.black;
    final Color subtitleColor =
    isSelected ? Colors.white70 : Colors.grey.shade600;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: InkWell(
        onTap: () => _toggleSelection(item.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? backgroundColor : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
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
                      _getIcon(item.id),
                      color: isSelected ? Colors.white : Colors.black,
                      size: 28,
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: titleColor)),
                  Text(item.subtitle,
                      style: TextStyle(fontSize: 12, color: subtitleColor)),
                  if (item.isRequired)
                    Text(
                      "필수 선택항목",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.red),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String id) {
    switch (id) {
      case 'safety':
        return Icons.security;
      case 'transport':
        return Icons.directions_bus;
      case 'life':
        return Icons.local_convenience_store;
      case 'community':
        return Icons.groups;
      default:
        return Icons.category;
    }
  }
}
