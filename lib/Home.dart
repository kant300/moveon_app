import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  double latitude = 0.0;
  double longitude = 0.0;
  int serviceCenter = 0;
  int policeStation = 0;
  int fireDepartment = 0;

  // geolocator 로 현재 위치 구하기
  void getCurrentLatLng() async {
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
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
        final response = await Dio().get("http://192.168.40.28:8080/living/data?code=$code");
        final data = response.data;
         print(data);

        // 현재 위치 기준으로 가장 가까운 거리 데이터 찾기 (미터 단위)
        double minDistance = double.infinity;
        dynamic nearest = {};
        for (var point in data) {
          double dist = Geolocator.distanceBetween(
              latitude, longitude, double.parse(point['위도']!), double.parse(point['경도']!)
          );
          if (dist < minDistance) {
            minDistance = dist;
            nearest = point;
          }
        }
         print("minDistance: $minDistance");
         print("nearest: $nearest");

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

  @override
  void initState() {
    super.initState();
    getCurrentLatLng();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("가장 가까운 공공시설 거리"),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text("경찰서 : 도보$policeStation분"),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text("소방서 : 도보$fireDepartment분"),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text("주민센터 : 도보$serviceCenter분"),
            ),
          ],
        ),
      )
    );
  }
}