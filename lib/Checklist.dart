import 'package:flutter/material.dart';

class Checklist extends StatefulWidget {
  ChecklistState createState() => ChecklistState();
}

class ChecklistState extends State<Checklist> {
  bool isChecked_1_1 = false;

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
                      Text(
                        "1. 정착 3일차",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 8),
                      Text(
                        isChecked_1_1 == true
                            ? "■"
                            : "□"
                                  "□",
                        style: TextStyle(fontSize: 28),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "정착할 때 필요한 과정들을 정리해놨어요",
                        style: TextStyle(fontSize: 16),
                      ),
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
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Container(
                        width: 330,
                        height: 130,
                        margin: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("주민센터 전입신고"),
                                  Checkbox(
                                    value: isChecked_1_1,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked_1_1 = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Text(
                                "신분증을 꼭 지참해주세요",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text("전입신고 페이지로 이동하기 >"),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 330,
                        height: 130,
                        margin: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Text("쓰레기 배출방법 확인"),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Text(
                                "분리수거 요일이 언제인지 확인해보세요",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text("쓰레기 배출정보 페이지로 이동하기 >"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
