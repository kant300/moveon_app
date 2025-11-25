import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  // 샘플 데이터
  List<Map<String, dynamic>> checklistStatus = [
    {"title": "아침 운동하기", "subtitle": "30분 조깅 또는 스트레칭", "isChecked": false},
    {"title": "책 읽기", "subtitle": "자기계발서 20쪽 읽기", "isChecked": true},
    {"title": "집안일 하기", "subtitle": "설거지와 빨래 정리", "isChecked": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Card(
              elevation: 4, // 그림자 깊이
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.all(10),
              child: Container(
                width: 350,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "개인 Check-list 진행사항",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        ("진행사항: ${checklistStatus.isNotEmpty ? checklistStatus.map((e) => e["isChecked"] ? "■" : "□").join() : "없음"}"),
                        style: TextStyle(fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () async {
                          dynamic result = await Navigator.pushNamed(
                            context,
                            "/checklistPersonal",
                            arguments: checklistStatus,
                          );
                          setState(() {
                            checklistStatus = result;
                          });
                        },
                        child: Text("개인 체크리스트 페이지로"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
