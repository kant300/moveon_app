import 'package:flutter/material.dart';

// 정착 체크리스트
class Checklist extends StatefulWidget {
  @override
  ChecklistState createState() => ChecklistState();
}

class ChecklistState extends State<Checklist> {
  // 체크리스트의 체크박스, 화면 상태
  List<List<bool>> isChecked = [
    [false, false, false, false, false, false, false],
    [false, false, false, false, false],
    [false, false, false, false, false],
  ];
  int checklistType = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is List<List<bool>>) {
      isChecked = args;
    }
  }

  // 화면 상태 변경 (체크리스트 개수 변동 시 clamp 의 값 수정)
  void updateChecklistType(int type) {
    setState(() {
      checklistType = type.clamp(0, 2);
    });
  }

  // 체크박스 상태 변경
  void updateCheckValue(int group, int index, bool value) {
    setState(() {
      isChecked[group][index] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, isChecked);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("정착 Check-list"),
      ),
      body: Column(
        children: [
          Expanded(
            // 상단 영역
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Color(0xFFEAEAEA),
              child: Center(
                child: Container(
                  // 상단 컨테이너
                  width: 350,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Color(0xFFC8EFFF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ChecklistTitle(
                    // 상단 컨테이너 내용
                    checklistType: checklistType,
                    checkValues: isChecked[checklistType],
                    onTypeChanged: updateChecklistType,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            // 하단 영역
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Color(0xFFADE7FF),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(5),
                child: ChecklistContent(
                  // 하단 컨테이너 내용
                  checklistType: checklistType,
                  checkValues: isChecked[checklistType],
                  onCheckChanged: (index, value) =>
                      updateCheckValue(checklistType, index, value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 정착 체크리스트의 상단 내용
class ChecklistTitle extends StatelessWidget {
  final int checklistType;
  final List<bool> checkValues;
  final ValueChanged<int> onTypeChanged;

  const ChecklistTitle({
    required this.checklistType,
    required this.checkValues,
    required this.onTypeChanged,
  });

  static const titles = ["정착 3일차", "정착 3주차", "정착 3개월차"];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          // 상단 타이틀
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${checklistType + 1}. ${titles[checklistType]}",
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              // back 버튼
              icon: Icon(Icons.arrow_back_ios),
              onPressed: checklistType > 0
                  ? () => onTypeChanged(checklistType - 1)
                  : null,
            ),
            Text(
              // 상단 진행사항 표시
              checkValues.map((e) => e ? "■" : "□").join(),
              style: TextStyle(fontSize: 28),
            ),
            IconButton(
              // forward 버튼
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: checklistType < 2
                  ? () => onTypeChanged(checklistType + 1)
                  : null,
            ),
          ],
        ),
        SizedBox(height: 12),
        Text("정착할 때 필요한 과정들을 정리해놨어요", style: TextStyle(fontSize: 16)),
      ],
    );
  }
}

// 정착 체크리스트의 하단 내용
class ChecklistContent extends StatelessWidget {
  final int checklistType;
  final List<bool> checkValues;
  final Function(int index, bool value) onCheckChanged;

  const ChecklistContent({
    required this.checklistType,
    required this.checkValues,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    final titles = checklistType == 0
        ? [
            "주민센터 전입신고",
            "쓰레기 배출방법 확인",
            "근처 편의점 찾기",
            "가까운 병원 위치 파악하기",
            "대중교통 노선 확인",
            "주변 반찬 가게 찾기",
            "야채 가게, 정육점 찾기",
          ]
        : checklistType == 1
        ? [
            "지역 커뮤니티 가입",
            "주민센터 프로그램 확인",
            "도서관 이용 등록",
            "공원 산책 루트 파악",
            "지역 SNS 팔로우",
          ]
        : checklistType == 2
        ? ["지역 이벤트 참여하기", "봉사활동 참여하기", "소모임 가입하기", "단골가게 만들기", "동네 친구 사귀기"]
        : [];

    final subtitles = checklistType == 0
        ? [
            "신분증을 꼭 지참해주세요",
            "분리수거 요일이 언제인지 확인해보세요",
            "근처에 있는 편의점의 위치를 확인해보세요",
            "근처에 있는 응급실이나 약국의 위치도 확인해보세요",
            "주변에 있는 대중교통의 노선표를 확인해보세요",
            "맛있는 반찬을 파는 가게들의 위치를 살펴보세요",
            "식재료들을 구할 수 있는 가게들의 위치입니다",
          ]
        : checklistType == 1
        ? [
            "동네 소식을 확인할 수 있어요",
            "취미로 즐길 수 있는 문화 활동들을 확인해보세요",
            "동네 맛집들을 살펴보고 방문해보세요",
            "머리 손질이 필요할 때 방문해보세요",
            "이웃 분들과 인사하며 관계를 키워보세요",
          ]
        : checklistType == 2
        ? [
            "커뮤니티 페이지로 이동하기 >",
            "문화 프로그램 확인하러 가기 >",
            "맛집 위치 확인하러 가기 >",
            "미용실 위치 확인하러 가기 >",
            "커뮤니티로 이동하기 >",
          ]
        : [];

    final buttonTexts = checklistType == 0
        ? [
            "전입신고 페이지로 이동하기 >",
            "쓰레기 배출정보 페이지로 이동하기 >",
            "편의점 위치 확인하러 가기 >",
            "병원 위치 파악하러 가기 >",
            "노선표 확인하러 가기 >",
            "반찬 가게 위치 찾기 >",
            "야채 가게, 정육점 위치 찾기 >",
          ]
        : checklistType == 1
        ? [
            "커뮤니티 페이지로 이동하기 >",
            "문화 프로그램 확인하러 가기 >",
            "맛집 위치 확인하러 가기 >",
            "미용실 위치 확인하러 가기 >",
            "커뮤니티로 이동하기 >",
          ]
        : checklistType == 2
        ? [
            "축제행사 페이지로 가기 >",
            "봉사활동 정보 확인하러 가기 >",
            "소모임 커뮤니티로 이동하기 >",
            "가게 찾으러 가기 >",
            "커뮤니티로 친구 사귀러 가기 >",
          ]
        : [];

    return Column(
      children: List.generate(checkValues.length, (index) {
        return ChecklistCard(
          // 체크리스트 카드 위젯
          title: titles[index],
          subtitle: subtitles[index],
          buttonText: buttonTexts[index],
          checkboxValue: checkValues[index],
          onCheckboxChanged: (value) => onCheckChanged(index, value),
        );
      }),
    );
  }
}

// 개인 체크리스트
class ChecklistPersonal extends StatefulWidget {
  ChecklistPersonalState createState() => ChecklistPersonalState();
}

class ChecklistPersonalState extends State<ChecklistPersonal> {
  // 체크리스트의 체크박스, 화면 상태
  List<Map<String, dynamic>> items = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is List<Map<String, dynamic>>) {
      items = List<Map<String, dynamic>>.from(args);
    }
  }

  // 체크박스 상태 변경
  void updateCheckValue(int index, bool value) {
    setState(() {
      items[index]["isChecked"] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, items);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("개인 Check-list"),
      ),
      body: Column(
        children: [
          Expanded(
            // 상단 영역
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Color(0xFFEAEAEA),
              child: Center(
                child: Container(
                  // 상단 컨테이너
                  width: 350,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Color(0xFFC8EFFF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    // 상단 컨테이너 내용
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("개인 Check-list", style: TextStyle(fontSize: 24)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            items.isNotEmpty
                                ? items
                                      .map((e) => e["isChecked"] ? "■" : "□")
                                      .join()
                                : "목록 없음",
                            style: TextStyle(fontSize: 28),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        "직접 목록을 추가하고 관리할 수 있습니다",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            // 하단 영역
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Color(0xFFADE7FF),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          // 최대 10개까지만 생성 가능
                          onPressed: () {
                            if (items.length < 10) {
                              String title;
                              String subtitle;

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Check-list 등록"),
                                  content: Column(
                                    children: [
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: "제목",
                                          hintText: "제목을 입력하세요",
                                        ),
                                        controller: titleController,
                                      ),
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: "내용",
                                          hintText: "내용을 입력하세요",
                                        ),
                                        controller: subtitleController,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, "취소"),
                                      child: Text("취소"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (titleController.text.isNotEmpty) {
                                          title = titleController.text.trim();
                                          subtitle = subtitleController.text
                                              .trim();

                                          setState(() {
                                            items.add({
                                              "title": title,
                                              "subtitle": subtitle,
                                              "isChecked": false,
                                            });
                                          });
                                          titleController.clear();
                                          subtitleController.clear();
                                          Navigator.pop(context, "등록");
                                        }
                                      },
                                      child: Text("등록"),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("최대 10개까지만 추가할 수 있습니다."),
                                ),
                              );
                            }
                          }, // 새로 추가하기 버튼
                          child: Text("+ 새로 추가하기"),
                        ),
                      ],
                    ),
                      ...List.generate(items.length, (index) {
                        return ChecklistCard(
                          title: items[index]["title"],
                          subtitle: items[index]["subtitle"],
                          onEdit: () {
                            print("수정: $index");
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("삭제 확인"),
                                  content: Text("정말로 삭제하시겠습니까?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("취소"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          items.removeAt(index);
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("삭제"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          checkboxValue: items[index]["isChecked"],
                          onCheckboxChanged: (value) =>
                              updateCheckValue(index, value),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 체크리스트 내용 카드
class ChecklistCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final bool? checkboxValue;
  final ValueChanged<bool>? onCheckboxChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ChecklistCard({
    required this.title,
    required this.subtitle,
    this.buttonText,
    required this.checkboxValue,
    required this.onCheckboxChanged,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 카드 컨테이너
      width: 330,
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 12, right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // 상단 타이틀, 체크박스
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                if (checkboxValue != null && onCheckboxChanged != null)
                  Checkbox(
                    value: checkboxValue,
                    onChanged: (val) {
                      if (val != null) onCheckboxChanged?.call(val);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            Text(subtitle, style: TextStyle(fontSize: 13)), // 중단 텍스트
            buttonText !=
                    null // 하단 이동 버튼, 또는 수정, 삭제 버튼
                ? TextButton(onPressed: () {}, child: Text(buttonText!))
                : Row(
                    children: [
                      TextButton(onPressed: onEdit, child: Text("수정")),
                      TextButton(onPressed: onDelete, child: Text("삭제")),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
