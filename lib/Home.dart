import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final dio = Dio();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final Map<String, dynamic> routeMap = {
    "공과금 정산": () => launchUrl(Uri.parse("https://www.gov.kr/portal/onestopSvc/transferReport")),
    "전입신고": () => launchUrl(Uri.parse("https://www.gov.kr/portal/onestopSvc/transferReport")),
    "의류수거함": (context) => Navigator.pushNamed(context, "/map", arguments: "clothingBin"),
    "쓰레기 배출": (context) => Navigator.pushNamed(context, "/living/trashInfo"),
    "폐가전 수거": () => launchUrl(Uri.parse("https://15990903.or.kr/portal/main/main.do")),
    "관공서": (context) => Navigator.pushNamed(context, "/map", arguments: "government"),
    "심야약국/병원": (context) => Navigator.pushNamed(context, "/map", arguments: "night"),
    "성범죄자": (context) => Navigator.pushNamed(context, "/map", arguments: "sexCrime"),
    "민간구급차": (context) => Navigator.pushNamed(context, "/safety/ambulance"),
    "비상급수시설": (context) => Navigator.pushNamed(context, "/safety/water"),
    "대피소": (context) => Navigator.pushNamed(context, "/map", arguments: "shelter"),
    "공중화장실": (context) => Navigator.pushNamed(context, "/map", arguments: "restroom"),
    "CCTV": (context) => Navigator.pushNamed(context, "/map", arguments: "cctv"),
    "지하철": (context) => Navigator.pushNamed(context, "/map", arguments: "subway"),
    "버스정류장": (context) => Navigator.pushNamed(context, "/transport/busStation"),
    "전동휠체어 충전소": (context) => Navigator.pushNamed(context, "/map", arguments: "wheelchairCharger"),
    "공용주차장": (context) => Navigator.pushNamed(context, "/map", arguments: "localParking"),
    "소분모임": (context) => Navigator.pushNamed(context, "/community/bulkBuy"),
    "지역행사": (context) => Navigator.pushNamed(context, "/community/localEvent"),
    "중고장터": (context) => Navigator.pushNamed(context, "/community/localStore"),
    "동네후기": (context) => Navigator.pushNamed(context, "/community/localActivity"),
    "구인/구직": (context) => Navigator.pushNamed(context, "/community/business"),
  };

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

  // 위치 가져오기
  Future<void> getCurrentLatLng() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('위치 서비스를 사용할 수 없습니다.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 거부되었습니다.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    loadWalkTime();
  }

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

  Future<int> getDistanceData(int code) async {
    try {
      if (latitude != 0.0 && longitude != 0.0) {
        final response = await Dio().get("http://10.0.2.2:8080/living/data?code=$code");
        final data = response.data;

        double minDistance = double.infinity;
        for (var point in data) {
          double dist = Geolocator.distanceBetween(
            latitude,
            longitude,
            double.parse(point['위도']!),
            double.parse(point['경도']!),
          );

          if (dist < minDistance) minDistance = dist;
        }

        double walkingTimeSec = minDistance / 1.4;
        return Duration(seconds: walkingTimeSec.round()).inMinutes;
      }
    } catch (e) {
      print(e);
    }
    return 0;
  }

  Future<void> getWeatherData() async {
    try {
      DateTime now = DateTime.now().add(Duration(hours: 9));
      String hour = DateFormat('HH').format(now);
      hour += '00';

      final response = await Dio().get("http://10.0.2.2:8080/weather", queryParameters: {
        "lat": latitude.toInt(),
        "lon": longitude.toInt(),
      });

      final data = jsonDecode(response.data);
      final items = data['response']['body']['items']['item'];

      dynamic t1h, pty, sky;

      for (dynamic obj in items) {
        if (hour == obj['fcstTime'].toString()) {
          if (obj['category'] == "T1H") t1h = obj['fcstValue'];
          if (obj['category'] == "PTY") pty = obj['fcstValue'];
          if (obj['category'] == "SKY") sky = obj['fcstValue'];
        }
      }

      // 강수형태 변환
      if (pty == "0") pty = "맑음";
      if (pty == "1") pty = "비";
      if (pty == "2") pty = "비/눈";
      if (pty == "3") pty = "눈";
      if (pty == "4") pty = "소나기";

      // 아이콘 설정
      dynamic icon;
      if (pty == "맑음") icon = const Icon(Icons.sunny);
      else if (pty == "비" || pty == "소나기") icon = const Icon(Icons.water_drop);
      else if (pty == "눈") icon = const Icon(Icons.snowing);
      else icon = const Icon(Icons.cloud);

      setState(() {
        this.t1h = t1h;
        this.pty = pty;
        this.hour = hour.substring(0, 2);
        weatherIcon = icon;
      });
    } catch (e) {
      print(e);
    }
  }

  void tokencall() async {
    final localsave = await SharedPreferences.getInstance();
    final logintoken = localsave.getString("logintoken");
    final guesttoken = localsave.getString("guestToken");

    print(" logintoken = $logintoken");
    print(" guestToken = $guesttoken");

    try {
      if (guesttoken != null) {
        await dio.get(
          "http://10.0.2.2:8080/api/guest/address",
          options: Options(headers: {"Authorization": "Bearer $guesttoken"}),
        );
      }

      if (logintoken != null) {
        await dio.get(
          "http://10.0.2.2:8080/api/member/info",
          options: Options(headers: {"Authorization": "Bearer $logintoken"}),
        );
      }
    } catch (e) {
      print("정보 불러오기 에러발생 $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initData();
    tokencall();
    wishlist();
  }

  Future<void> _initData() async {
    await getCurrentLatLng();
    await getWeatherData();
  }

  List<String> wishposi = [];

  void wishlist() async {
    try {
      final localsave = await SharedPreferences.getInstance();
      final logintoken = localsave.getString('logintoken');
      final guesttoken = localsave.getString("guestToken");

      if (logintoken != null) {
        final response = await dio.get(
          "http://10.0.2.2:8080/api/member/wishprint",
          options: Options(headers: {"Authorization": "Bearer $logintoken"}),
        );
        setState(() {
          wishposi = (response.data['success'] ?? "").toString().split(",");
        });
      } else if (guesttoken != null) {
        final response = await dio.get(
          "http://10.0.2.2:8080/api/guest/address",
          options: Options(headers: {"Authorization": "Bearer $guesttoken"}),
        );
        setState(() {
          wishposi = (response.data['wishlist'] ?? "").toString().split(",");
        });
      }
    } catch (e) {
      print("즐겨찾기 불러오기 에러 $e");
    }
  }

  final Map<String, IconData> iconMap = {
    "공과금 정산": Icons.attach_money,
    "전입신고": Icons.person_pin_circle_rounded,
    "의류수거함": Icons.checkroom,
    "쓰레기 배출": Icons.recycling,
    "폐가전 수거": Icons.energy_savings_leaf,
    "관공서": Icons.local_police,
    "심야약국/병원": Icons.local_hospital,
    "성범죄자": Icons.crisis_alert,
    "민간구급차": Icons.medical_information,
    "비상급수시설": Icons.water_drop,
    "대피소": Icons.night_shelter,
    "공중화장실": Icons.wc,
    "CCTV": Icons.video_camera_back,
    "지하철": Icons.subway_outlined,
    "버스정류장": Icons.directions_bus,
    "전동휠체어 충전소": Icons.ev_station,
    "공용주차장": Icons.local_parking,
    "소분모임": Icons.handshake,
    "지역행사": Icons.event_note,
    "중고장터": Icons.shopping_bag,
    "동네후기": Icons.reviews,
    "구인/구직": Icons.business_center,
  };

  // ⭐ 오버플로우 방지 적용된 즐겨찾기
  Widget iconGrid() {
    if (wishposi.isEmpty || wishposi[0].isEmpty) {
      return Text("즐겨찾기가 없습니다.");
    }

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: wishposi.map((label) {
        final icon = iconMap[label];
        final route = routeMap[label];

        if (icon == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            if (route != null) {
              if (route is Function(BuildContext)) {
                route(context);
              } else {
                route();
              }
            }
          },
          child: SizedBox(
            width: 70, // 고정 폭 → 절대 오버플로우 안남
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 30),
                ),
                SizedBox(height: 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
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
                color: Color(0xFFE0F7FA),
                elevation: 4,
                child: ListTile(
                  leading: weatherIcon,
                  title: Text(
                    '현재 날씨 정보 ($hour시 기준)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  subtitle: Text('$t1h°C, $pty', style: TextStyle(color: Colors.blueGrey)),
                ),
              ),
            ),

            // 거리 카드 3개
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(child: infoCard("경찰서", policeStation)),
                  Expanded(child: infoCard("소방서", fireDepartment)),
                  Expanded(child: infoCard("주민센터", serviceCenter)),
                ],
              ),
            ),

            // 체크리스트
            checklistCard(),

            // 즐겨찾기
            favoriteCard(),
          ],
        ),
      ),
    );
  }

  Widget infoCard(String title, int time) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 60,
        alignment: Alignment.center,
        child: Text("$title\n도보${time}분", textAlign: TextAlign.center),
      ),
    );
  }

  Widget checklistCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.all(10),
      child: Container(
        width: 350,
        height: 150,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("정착 Check-list 진행사항", style: TextStyle(fontSize: 16)),
            Text("3일차: ${checklistStatus[0].map((e) => e ? "■" : "□").join()}"),
            Text("3주차: ${checklistStatus[1].map((e) => e ? "■" : "□").join()}"),
            Text("3개월차: ${checklistStatus[2].map((e) => e ? "■" : "□").join()}"),
            TextButton(
              onPressed: () async {
                dynamic result = await Navigator.pushNamed(context, "/checklist", arguments: checklistStatus);
                setState(() => checklistStatus = result);
              },
              child: Text("정착지수 페이지로"),
            ),
          ],
        ),
      ),
    );
  }

  Widget favoriteCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.all(10),
      child: Container(
        width: 350,
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Text("즐겨찾기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            iconGrid(),
          ],
        ),
      ),
    );
  }
}
