import 'package:flutter/material.dart';

// 카테고리 데이터를 위한 구조체
class CategoryItem {
  final String label;
  final String categoryKey; // 마커 로드에 사용되는 키 (e.g., "clothingBin")

  CategoryItem(this.label, this.categoryKey);
}

// 주 카테고리 데이터를 위한 구조체
class MainCategory {
  final String title;
  final List<CategoryItem> subCategories;

  MainCategory(this.title, this.subCategories);
}


class VerticalHorizontalCategoryList extends StatefulWidget {
  final Function(String) onCategorySelected;

  const VerticalHorizontalCategoryList({super.key, required this.onCategorySelected});

  @override
  _VerticalHorizontalCategoryListState createState() => _VerticalHorizontalCategoryListState();
}

class _VerticalHorizontalCategoryListState extends State<VerticalHorizontalCategoryList> {

  // 현재 선택된 주 카테고리
  String? _selectedMainCategoryTitle;

  // 카테고리 데이터 구성
  final List<MainCategory> _categories = [
    MainCategory('생활', [
      CategoryItem("의류수거함", "clothingBin"),
      CategoryItem("관공서", "government"),
      CategoryItem("약국/병원", "night"),
      ]),
    MainCategory('안전', [
      CategoryItem("성범죄자", "sexCrime"),
      //CategoryItem("CCTV", " "),
      CategoryItem("대피소", "shelter"),
      CategoryItem("공중화장실", "restroom"),
    ]),
    MainCategory('교통', [
      CategoryItem("지하철/승강기", "subwayLift"),
      CategoryItem("지하철/배차", "subwaySchedule"),
      CategoryItem("전동휠체어", "wheelchairCharger"),
      CategoryItem("공영주차장", "localParking"),
    ]),
  ];


  @override
  Widget build(BuildContext context) {
    // 현재 선택된 주 카테고리의 하위 목록
    final selectedSubCategories = _categories
        .firstWhere(
          (cat) => cat.title == _selectedMainCategoryTitle,
          orElse: () => MainCategory('', []),
        )
        .subCategories;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 주 카테고리 버튼 (수직/세로 나열)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _categories.map((mainCategory) {
              final isSelected = mainCategory.title == _selectedMainCategoryTitle;

              return SizedBox(
                width: 70, // 주 카테고리 버튼 너비 고정
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.15) : Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  onPressed: () {
                    setState(() {
                      // 이미 선택된 카테고리를 다시 클릭하면 닫기
                      if (isSelected) {
                        _selectedMainCategoryTitle = null;
                      } else {
                        _selectedMainCategoryTitle = mainCategory.title;
                      }
                    });
                  },
                  child: Text(
                    mainCategory.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // 2. 하위 카테고리 버튼 (주 카테고리 옆에 수평/가로로 펼쳐짐)
        if (_selectedMainCategoryTitle != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),// 주 카테고리와 간격
            child: Container(
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(maxHeight: 50), // 높이 제한
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              // 하위 카테고리를 수평으로 나열
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: selectedSubCategories.map((subCategory) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                          ),
                        ),
                        onPressed: () {
                          // 하위 카테고리 선택 시 마커 로드 후 목록 닫기
                          widget.onCategorySelected(subCategory.categoryKey);
                          setState(() {
                            _selectedMainCategoryTitle = null; // 목록 닫기
                          });
                        },
                        child: Text(
                          subCategory.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}