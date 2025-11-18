import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  List<bool> checklistStatus = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.all(10),
              width: 350,
              height: 100,
              child: Center(
                child: Column(
                  children: [
                    Text("개인 Check-list 진행사항", style: TextStyle(fontSize: 16)),
                    Text(
                      ("진행사항: ${checklistStatus.map((e) => e ? "■" : "□").join()}"),
                      style: TextStyle(fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () async {
                        dynamic result = await Navigator.pushNamed(
                          context,
                          "/checklist", // TODO
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
          ],
        ),
      ),
    );
  }
}
