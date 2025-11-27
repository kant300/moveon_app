import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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
  // -----------------------------
  // ROUTE MAP
  // -----------------------------
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

  // -----------------------------
  // VARIABLES
  // -----------------------------
  double latitude = 0.0;
  double longitude = 0.0;

  dynamic t1h, pty, hour, weatherIcon;
  dynamic administrativeArea, locality;

  int serviceCenter = 0;
  int policeStation = 0;
  int fireDepartment = 0;

  List<String> wishposi = [];
  List<List<bool>> checklistStatus = [
    [false, false, false, false, false, false, false],
    [false, false, false, false, false],
    [false, false, false, false, false],
  ];

  // -----------------------------
  // CCTV / 성범죄자
  // -----------------------------
  bool isLoadingCctv = false;
  int cctvCount = 0;
  String currentDong = "";

  bool isLoadingCrime = false;
  int dongCount = 0;

  // -----------------------------
  // INIT
  // -----------------------------
  @override
  void initState() {
    super.initState();
    _initData();
    tokencall();
    wishlist();

    Future.delayed(Duration(milliseconds: 500), () async {
      await _loadCctv();
      await _loadSexCrime();
      await _loadAddressName();
    });
  }

  // -----------------------------
  // 위치 + 날씨
  // -----------------------------
  Future<void> _initData() async {
    await getCurrentLatLng();
    await getWeatherData();
  }

  // GPS
  Future<void> getCurrentLatLng() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    loadWalkTime();
  }

  // -----------------------------
  // 도보 거리
  // -----------------------------
  Future<int> getDistanceData(int code) async {
    try {
      if (latitude == 0 || longitude == 0) return 0;

      final response = await Dio().get(
        "http://10.95.125.46:8080/living/data?code=$code",
      );
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

      double walkingSpeed = 1.4;
      return Duration(seconds: (minDistance / walkingSpeed).round()).inMinutes;
    } catch (e) {
      return 0;
    }
  }

  void loadWalkTime() async {
    int s = await getDistanceData(1003);
    int p = await getDistanceData(1015);
    int f = await getDistanceData(4001);

    setState(() {
      serviceCenter = s;
      policeStation = p;
      fireDepartment = f;
    });
  }

  // -----------------------------
  // 날씨 API
  // -----------------------------
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
      print("날씨 $data");
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

      // 현재 위치 정보
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];

      setState(() {
        this.t1h = t1h;
        this.pty = pty;
        this.hour = hour;
        weatherIcon = icon;
        administrativeArea = place.administrativeArea;
        locality = place.locality;
      });
    } catch (e) {
      print(e);
    }
  }

  // -----------------------------
  // CCTV 불러오기
  // -----------------------------
  Future<void> _loadCctv() async {
    if (latitude == 0 || longitude == 0) return;

    setState(() => isLoadingCctv = true);

    try {
      final response = await dio.get(
        'http://10.95.125.46:8080/api/cctv/count-by-dong',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          cctvCount = response.data['cctv_count'];
        });
      }
    } catch (e) {
      print("CCTV error: $e");
    } finally {
      setState(() => isLoadingCctv = false);
    }
  }

  // -----------------------------
  // 성범죄자 수
  // -----------------------------
  Future<void> _loadSexCrime() async {
    if (latitude == 0 || longitude == 0) return;

    setState(() => isLoadingCrime = true);

    try {
      final response = await dio.get(
        'http://10.95.125.46:8080/api/sex-crime/dong-count',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          dongCount = response.data["count"];
        });
      }
    } catch (e) {
      print("성범죄자 오류: $e");
    } finally {
      setState(() => isLoadingCrime = false);
    }
  }

  // -----------------------------
  // 현재 동 이름 가져오기
  // -----------------------------
  Future<void> _loadAddressName() async {
    try {
      final placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      setState(() {
        currentDong = placemarks[0].subLocality ?? "";
      });
    } catch (e) {
      print("동 이름 오류: $e");
    }
  }

  // -----------------------------
  // TOKEN CHECK
  // -----------------------------
  void tokencall() async {
    final sp = await SharedPreferences.getInstance();

    final logintoken = sp.getString("logintoken");
    final guesttoken = sp.getString("guestToken");

    if (guesttoken != null) {
      final response = await dio.get(
        "http://10.95.125.46:8080/api/guest/address",
        options: Options(headers: {"Authorization": "Bearer $guesttoken"}),
      );
      print(response.data);
    }

    if (logintoken != null) {
      final response = await dio.get(
        "http://10.95.125.46:8080/api/member/info",
        options: Options(headers: {"Authorization": "Bearer $logintoken"}),
      );
      print(response.data);
    }
  }

  // -----------------------------
  // 즐겨찾기
  // -----------------------------
  void wishlist() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final logintoken = sp.getString("logintoken");
      final guesttoken = sp.getString("guestToken");

      if (logintoken != null) {
        final response = await dio.get(
          "http://10.95.125.46:8080/api/member/wishprint",
          options: Options(headers: {"Authorization": "Bearer $logintoken"}),
        );
        setState(() {
          wishposi =
              (response.data['success'] ?? "").toString().split(",");
        });
      } else if (guesttoken != null) {
        final response = await dio.get(
          "http://10.95.125.46:8080/api/guest/address",
          options: Options(headers: {"Authorization": "Bearer $guesttoken"}),
        );
        setState(() {
          wishposi =
              (response.data['wishlist'] ?? "").toString().split(",");
        });
      }
    } catch (e) {
      print("위시리스트 오류");
    }
  }

  // -----------------------------
  // 즐겨찾기 아이콘 GRID
  // -----------------------------
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
    if (wishposi.isEmpty || wishposi[0].isEmpty) {
      return Text("즐겨찾기가 없습니다.");
    }

    return Wrap(
      spacing: 15,
      runSpacing: 10,
      children: wishposi.map((label) {
        final icon = iconMap[label];
        final route = routeMap[label];

        if (icon == null) return SizedBox.shrink();

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
          child: Column(
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

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(   // 오버플로우 해결
        child: Column(
          children: [
            SizedBox(height: 30),

            // ------------------ 날씨 카드 ------------------
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                color: Color(0xFFE0F7FA),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.water_drop),
                  title: Text(
                    '인천 부평구 날씨 (12시)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  subtitle: Text(
                    '6°C / 비',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ),
            ),

            // ------------------ 공공시설 거리 ------------------
            Padding(
              padding: EdgeInsets.only(left: 12, right: 12),
              child: Row(
                children: [
                  Expanded(child: _distanceCard("경찰서", policeStation)),
                  Expanded(child: _distanceCard("소방서", fireDepartment)),
                  Expanded(child: _distanceCard("주민센터", serviceCenter)),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ------------------ CCTV + 성범죄자 ------------------
            Text("내 동네 안전정보",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(child: _cctvCard()),
                  SizedBox(width: 10),
                  Expanded(child: _crimeCard()),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ------------------ 체크리스트 ------------------
            _checklistCard(),

            // ------------------ 즐겨찾기 ------------------
            _favoriteCard(),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // 카드 UI 컴포넌트
  // -----------------------------
  Widget _distanceCard(String title, int minute) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 70,
        alignment: Alignment.center,
        child: Text("$title\n도보 ${minute}분",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _cctvCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 70,
        alignment: Alignment.center,
        child: isLoadingCctv
            ? CircularProgressIndicator(strokeWidth: 2)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(currentDong, style: TextStyle(fontSize: 11)),
            Text("CCTV ${cctvCount}대",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _crimeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 70,
        alignment: Alignment.center,
        child: isLoadingCrime
            ? CircularProgressIndicator(strokeWidth: 2)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(currentDong, style: TextStyle(fontSize: 11)),
            Text("성범죄자 ${dongCount}명",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _checklistCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.all(10),
      child: Container(
        width: 350,
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("정착 Check-list 진행사항",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("3일차: ${checklistStatus[0].map((e) => e ? "■" : "□").join()}"),
            Text("3주차: ${checklistStatus[1].map((e) => e ? "■" : "□").join()}"),
            Text("3개월차: ${checklistStatus[2].map((e) => e ? "■" : "□").join()}"),
            TextButton(
              onPressed: () async {
                dynamic result = await Navigator.pushNamed(
                  context,
                  "/checklist",
                  arguments: checklistStatus,
                );
                setState(() => checklistStatus = result);
              },
              child: Text("정착지수 페이지로"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _favoriteCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.all(10),
      child: Container(
        width: 350,
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Text("즐겨찾기",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 18),
            iconGrid(),
          ],
        ),
      ),
    );
  }
}
