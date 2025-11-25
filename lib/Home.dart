import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:moveon_app/weather/WeatherWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final dio=Dio();
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
          "http://10.0.2.2:8080/living/data?code=$code",
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
        "http://10.0.2.2:8080/weather",
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
    catch (e) {
      print("정보 불러오기 에러발생 $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initData();
    tokencall();
    print("회원정보 불러오기");
    wishlist();
    print("즐겨찾기 불러오기");
  }

  List<String> wishposi = [];

  void wishlist() async {
    try {
      final localsave = await SharedPreferences.getInstance();
      final logintoken = localsave.getString('logintoken');
      final guesttoken = localsave.getString("guestToken");

      String? token = logintoken ?? guesttoken;
      if (token == null) {
        print("토큰 없음 $token");
        return;
      }

      if (logintoken != null) {
        final response = await dio.get(
          "http://10.0.2.2:8080/api/member/wishprint",
          options: Options(headers: {"Authorization": "Bearer $logintoken"}),
        );
        final data = response.data;
        setState(() {
          wishposi = (data['success'] ?? "").toString().split(",");
        });
        print("회원 즐겨찾기 가져오기 $wishposi ");

      } else if (guesttoken != null) {
        final response = await dio.get(
          "http://10.0.2.2:8080/api/guest/address",
          options: Options(headers: {"Authorization": "Bearer $guesttoken"}),
        );
        print("게스트 즐겨찾기 가져오기");
        final data = response.data;
        setState(() {
          wishposi = (data['wishlist'] ?? "").toString().split(",");
        });
      }

      print("즐겨찾기 확인$wishposi");
    } catch (e) {
      print("즐겨찾기 불러오기 에러 $e");
    }
  }

  // 비동기 작업 순서를 보장하기 위한 함수
  Future<void> _initData() async {
    await getCurrentLatLng();   // 위치값을 먼저 가져옴
    await getWeatherData();     // 위치값이 준비된 후 날씨 요청
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

  Widget iconGrid() {
    if(wishposi.isEmpty || wishposi[0].isEmpty){
    return Text("즐겨찾기가 없습니다.");
    }

    return Wrap(
      spacing: 15,
      runSpacing: 10,
      children: wishposi.map((label) {
        final icon = iconMap[label];
        final route = routeMap[label];
        if(icon == null ) return SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            if(route != null){
              if(route is Function(BuildContext)) {
                route(context);
              }else{
                route();
              }
            }
          },
         child:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Icon(icon, size: 30),
            ),
            SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
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

            // 즐겨찾기 홈
            Card(
              elevation: 6, // 그림자 깊이
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.all(10),
              child: Container(
                alignment: Alignment.center,
                width: 350,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height : 8),
                      Text("즐겨찾기", style: TextStyle(fontSize: 16, fontWeight:  FontWeight.bold),
                      ),
                      SizedBox(height: 30),
                      iconGrid(),
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
