import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio=Dio();

class MyPage extends StatefulWidget {
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokencall();
  }


  // 샘플 데이터
  List<Map<String, dynamic>> checklistStatus = [
    {"title": "아침 운동하기", "subtitle": "30분 조깅 또는 스트레칭", "isChecked": false},
    {"title": "책 읽기", "subtitle": "자기계발서 20쪽 읽기", "isChecked": true},
    {"title": "집안일 하기", "subtitle": "설거지와 빨래 정리", "isChecked": false},
  ];

  void tokencall() async {
    final localsave = await SharedPreferences.getInstance();

    final logintoken = localsave.getString("logintoken");
    final guesttoken = localsave.getString("guestToken");

    print(" logintoken = $logintoken");
    print(" guestToken = $guesttoken");


    try {
      if (guesttoken != null) {
        print(" 게스트 토큰 감지");

        final response = await dio.get(
          "http://10.0.2.2:8080/api/guest/address",
          options: Options(headers: {"Authorization": "Bearer $guesttoken"}),
        );

        final data = response.data;

        print(" 게스트 주소 데이터: $data");
      }

      // 2 회원 토큰 처리
      if (logintoken != null) {
        print(" 회원 토큰 감지");
        final response = await dio.get(
          "http://10.0.2.2:8080/api/member/info",
          options: Options(headers: {"Authorization": "Bearer $logintoken"}),
        );

        final data = response.data;

        print(" 회원 주소 데이터: $data");
      }
    }
    catch(e){ print("정보 불러오기 에러발생 $e"); }
  }


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
