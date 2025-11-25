import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:moveon_app/weather/WeatherWidget.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  double latitude = 0.0;
  double longitude = 0.0;
  int serviceCenter = 0;
  int policeStation = 0;
  int fireDepartment = 0;
  dynamic t1h, pty, hour, weatherIcon;
  List<List<bool>> checklistStatus = [
    [false, false, false, false, false, false, false],
    [false, false, false, false, false],
    [false, false, false, false, false],
  ];

  // geolocator 로 현재 위치 구하기
  Future<void> getCurrentLatLng() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스를 사용할 수 없습니다.');
    }

    // 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다.');
    }

    // 현재 위치 구하기
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    // 도보 이동 시간 불러오기
    loadWalkTime();
  }

  // 도보 이동 시간 불러오기
  void loadWalkTime() async {
    int serviceCenterWalkTime = await getDistanceData(1003);
    int policeStationWalkTime = await getDistanceData(1015);
    int fireDepartmentWalkTime = await getDistanceData(4001);

    setState(() {
      serviceCenter = serviceCenterWalkTime;
      policeStation = policeStationWalkTime;
      fireDepartment = fireDepartmentWalkTime;
    });
  }

  // 거리 정보 구하기
  Future<int> getDistanceData(int code) async {
    try {
      // 현재 위치 데이터가 있는지 확인
      if (latitude != 0.0 && longitude != 0.0) {
        // 분류 코드로 통신하여 데이터 가져오기
        final response = await Dio().get(
          "http://192.168.40.28:8080/living/data?code=$code",
        );
        final data = response.data;
        // print(data);

        // 현재 위치 기준으로 가장 가까운 거리 데이터 찾기 (미터 단위)
        double minDistance = double.infinity;
        dynamic nearest = {};
        for (var point in data) {
          double dist = Geolocator.distanceBetween(
            latitude,
            longitude,
            double.parse(point['위도']!),
            double.parse(point['경도']!),
          );
          if (dist < minDistance) {
            minDistance = dist;
            nearest = point;
          }
        }
        // print("minDistance: $minDistance");
        // print("nearest: $nearest");

        // 이동 시간을 구해서 반환하기 (도보 기준)
        double walkingSpeed = 1.4; // m/s
        double walkingTimeSec = minDistance / walkingSpeed;

        Duration walkingDuration = Duration(seconds: walkingTimeSec.round());
        return walkingDuration.inMinutes;
      }
    } catch (e) {
      print(e);
    }
    // 현재 위치가 없거나, 오류 발생 시 0 반환
    return 0;
  }

  // 날씨 정보 구하기
  Future<void> getWeatherData() async {
    try {
      // 현재 시간 (HH시) 가져오기
      // UTC -> KST 시간으로 변경 (9시간 추가)
      DateTime now = DateTime.now().add(Duration(hours: 9));
      String hour = DateFormat('HH').format(now);
      int lat = latitude.toInt();
      int lon = longitude.toInt();

      final response = await Dio().get(
        "http://192.168.40.28:8080/weather",
        queryParameters: {"lat": lat, "lon": lon},
      );
      final data = jsonDecode(response.data);
      final items = data['response']['body']['items']['item'];

      // 필요한 데이터 가져오기
      hour += '00';
      dynamic t1h, reh, pty, sky, wsd;
      for (dynamic obj in items) {
        if (hour == obj['fcstTime'].toString()) {
          if (obj['category'] == "T1H") {
            t1h = obj['fcstValue']; // 기온
          }
          if (obj['category'] == "REH") {
            reh = obj['fcstValue']; // 습도
          }
          if (obj['category'] == "PTY") {
            pty = obj['fcstValue']; // 강수형태
            if (pty == "0") pty = "맑음";
            if (pty == "1") pty = "비";
            if (pty == "2") pty = "비/눈";
            if (pty == "3") pty = "눈";
            if (pty == "4") pty = "소나기";
            if (pty == "5") pty = "빗방울";
            if (pty == "6") pty = "빗방울눈날림";
            if (pty == "7") pty = "눈날림";
          }
          if (obj['category'] == "SKY") {
            sky = obj['fcstValue']; // 하늘상태
            if (sky == "1") sky = "맑음";
            if (sky == "3") sky = "구름많음";
            if (sky == "4") sky = "흐림";
          }
          if (obj['category'] == "WSD") {
            wsd = obj['fcstValue']; // 풍속
          }
        }
      }
      hour = hour.substring(0, 2);

      // 날씨에 따른 아이콘 그리기
      dynamic icon;
      if (pty == "맑음" && sky == "맑음") {
        icon = const Icon(Icons.sunny);
      } else if (sky == "구름많음") {
        icon = const Icon(Icons.cloud);
      } else if (sky == "흐림") {
        icon = const Icon(Icons.foggy);
      } else if (pty == "비" || pty == "비/눈" || pty == "소나기") {
        icon = const Icon(Icons.water_drop);
      } else if (pty == "눈") {
        icon = const Icon(Icons.snowing);
      }

      setState(() {
        this.t1h = t1h;
        this.pty = pty;
        this.hour = hour;
        weatherIcon = icon;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // 비동기 작업 순서를 보장하기 위한 함수
  Future<void> _initData() async {
    await getCurrentLatLng();   // 위치값을 먼저 가져옴
    await getWeatherData();     // 위치값이 준비된 후 날씨 요청
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                color: Color(0xFFE0F7FA), // Light Cyan background
                elevation: 4,
                child: ListTile(
                  leading: weatherIcon,
                  title: Text(
                    '현재 날씨 정보 ($hour시 기준)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  subtitle: Text(
                    '$t1h°C, $pty',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ),
            ),
            //Text("가장 가까운 공공시설 거리"),
            Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(
                          "경찰서\n도보$policeStation분",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(
                          "소방서\n도보$fireDepartment분",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(
                          "주민센터\n도보$serviceCenter분",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              elevation: 6, // 그림자 깊이
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
                        "정착 Check-list 진행사항",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        ("3일차: ${checklistStatus[0].map((e) => e ? "■" : "□").join()}"),
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        ("3주차: ${checklistStatus[1].map((e) => e ? "■" : "□").join()}"),
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        ("3개월차: ${checklistStatus[2].map((e) => e ? "■" : "□").join()}"),
                        style: TextStyle(fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () async {
                          dynamic result = await Navigator.pushNamed(
                            context,
                            "/checklist",
                            arguments: checklistStatus,
                          );
                          setState(() {
                            checklistStatus = result;
                          });
                        },
                        child: Text("정착지수 페이지로"),
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
