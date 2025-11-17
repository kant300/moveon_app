import 'package:flutter/material.dart';

class Checklist extends StatefulWidget {
  @override
  ChecklistState createState() => ChecklistState();
}

class ChecklistState extends State<Checklist> {
  bool isChecked_1_1 = false;
  bool isChecked_1_2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: Text("정착 Check-list")),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Color(0xFFEAEAEA),
              child: Center(
                child: Container(
                  width: 350,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Color(0xFFC8EFFF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("1. 정착 3일차", style: TextStyle(fontSize: 24)),
                      SizedBox(height: 8),
                      Text(
                          (isChecked_1_1 ? "■" : "□") +
                          (isChecked_1_2 ? "■" : "□"),
                          style: TextStyle(fontSize: 28)),
                      SizedBox(height: 12),
                      Text("정착할 때 필요한 과정들을 정리해놨어요", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Color(0xFFADE7FF),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    ChecklistCard(
                      title: "주민센터 전입신고",
                      subtitle: "신분증을 꼭 지참해주세요",
                      buttonText: "전입신고 페이지로 이동하기 >",
                      checkboxValue: isChecked_1_1,
                      onCheckboxChanged: (value) => setState(() => isChecked_1_1 = value),
                    ),
                    ChecklistCard(
                      title: "쓰레기 배출방법 확인",
                      subtitle: "분리수거 요일이 언제인지 확인해보세요",
                      buttonText: "쓰레기 배출정보 페이지로 이동하기 >",
                      checkboxValue: isChecked_1_2,
                      onCheckboxChanged: (value) => setState(() => isChecked_1_2 = value),
                    ),
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

class ChecklistCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final bool? checkboxValue;
  final ValueChanged<bool>? onCheckboxChanged;

  const ChecklistCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.checkboxValue,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Text(subtitle, style: TextStyle(fontSize: 13)),
            TextButton(onPressed: () {}, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}