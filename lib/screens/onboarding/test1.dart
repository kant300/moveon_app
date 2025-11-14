import 'package:flutter/material.dart';
import 'package:moveon_app/screens/onboarding/OnboardingComplete.dart';
// 카테고리 데이터 모델
class CategoryItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isRequired;

  CategoryItem({required this.id, required this.title, required this.subtitle, this.isRequired = false});
}

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
    CategoryItem(id: 'safety', title: '안전', subtitle: '치안, 안전시설', isRequired: true),
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
  int get _selectedCount => _categorySelections.values.where((selected) => selected).length;

  // 4. 카드 클릭 이벤트 처리 함수
  void _toggleSelection(String categoryId) {
    // 안전(필수항목)은 선택 해제 불가
    if (categoryId == 'safety') return;

    setState(() {
      // 현재 상태의 반대값으로 토글
      _categorySelections[categoryId] = !(_categorySelections[categoryId] ?? false);
    });
  }

  // 카테고리 ID에 따른 색상 정의
  Color _getCategoryColor(String id) {
    switch (id) {
      case 'safety':
        return Colors.red.shade600; // 안전: 빨강
      case 'transport':
        return Colors.blue.shade600; // 교통: 파랑
      case 'life':
        return const Color(0xFF3DE0D2); // 생활: 청록
      case 'community':
        return Colors.orange.shade700; // 커뮤니티: 주황/노랑 계열
      default:
        return Colors.grey.shade500;
    }
  }

  // 5. Build 메서드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar의 기본 그림자 제거 (이미지와 일치시키기 위해)
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body:Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Progress Bar ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _colorBar(const Color(0xFF3DE0D2)),   // 1단계 (완료)
                const SizedBox(width: 24),
                _colorBar(const Color(0xFF3DE0D2)),   // 2단계 (현재)
                const SizedBox(width: 24),
                _colorBar(const Color(0xFFC5F6F6)),   // 3단계 (미완료)
              ],
            ),
            const SizedBox(height: 32),

            // --- 2. Title & Subtitle ---
            const Text(
              "어떤 정보가 필요하신가요?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "관심있은 정보를 모두 선택해주세요",
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),

            // --- 3. Category Cards (2x2 Layout) ---
            Expanded(
              child: Column(
                children: [
                  // 1행: 안전, 교통
                  Expanded(
                    child: Row(
                      children: [
                        _buildCategoryCard(_categories[0]), // 안전
                        const SizedBox(width: 20),
                        _buildCategoryCard(_categories[1]), // 교통
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 2행: 생활, 커뮤니티
                  Expanded(
                    child: Row(
                      children: [
                        _buildCategoryCard(_categories[2]), // 생활
                        const SizedBox(width: 20),
                        _buildCategoryCard(_categories[3]), // 커뮤니티
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 4. Bottom Selection Count and Buttons ---
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 16),
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
                          ),
                          child: const Text("이전", style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 다음 버튼 (활성화/비활성화)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedCount > 0
                              ? () {
                            // "다음" 버튼 클릭 시 다음 페이지로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnboardingComplete(), // 설정완료 페이지로 이동
                              ),
                            );
                          }
                              : null, // 선택된 항목이 없으면 버튼 비활성화
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: _selectedCount > 0 ? const Color(0xFF3DE0D2) : Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: const Text("다음"),
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
  Widget _buildCategoryCard(CategoryItem item) {
    final bool isSelected = _categorySelections[item.id] ?? false;



    // 선택 여부에 따른 배경색 및 글자색 설정
    final Color selectedBgColor = _getCategoryColor(item.id);
    final Color selectedTextColor = Colors.white;
    final Color unselectedBgColor = Colors.white;
    final Color unselectedTextColor = Colors.black;

    final Color backgroundColor = isSelected ? selectedBgColor : unselectedBgColor;
    final Color titleColor = isSelected ? selectedTextColor : unselectedTextColor;
    final Color subtitleColor = isSelected ? selectedTextColor.withOpacity(0.7) : Colors.grey.shade600;

    return Expanded(
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
            boxShadow: isSelected ? [
              BoxShadow(
                color: selectedBgColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
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
                      color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
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
                          item.isRequired ? Icons.close : Icons.check, // 필수는 닫기 대신 체크로 변경 (이미지 반영)
                          color: item.isRequired ? Colors.red.shade600 : selectedBgColor,
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
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                  if (item.isRequired)
                    Text(
                      "필수 선택항목",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? selectedTextColor : Colors.red.shade600,
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
