import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moveon_app/screens/onboarding/OnboardingCategory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

final dio = Dio();

class OnboardingAddress extends StatefulWidget {
  const OnboardingAddress({super.key});

  @override
  OnboardingAddressState createState() => OnboardingAddressState();
}

class OnboardingAddressState extends State<OnboardingAddress> {
  late WebViewController MapController;

  // ⭐️ 버튼 스타일링을 위해 색상 상수 정의
  final Color _mainTealColor = const Color(0xFF3DE0D2);
  final Color _nextButtonBgColor = const Color(0xFF3DE0D2); // 다음 버튼의 배경색 (참고 코드의 노란색)
  final Color _nextButtonTextColor = Colors.white; // 다음 버튼의 텍스트 색상 (_mainTealColor)

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    MapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'MapClick',
        onMessageReceived: (msg) async {
          final gpsmap = jsonDecode(msg.message);
          double lat = gpsmap['lat'];
          double lon = gpsmap['lon'];
          print("좌표 전달 ${msg.message}");
          String address = await getKakaomap(lon, lat);

          setState(() {
            addressCont.text =
                address; // lon , lat / 윋 ㅗ경도 주소 address 로 받아서  input text에 넣어줌
          });
        },
      );
  }

  TextEditingController addressCont = TextEditingController();

  bool showMap = false;
  double? lat; // WebView 사용
  double? lon; // WebView 사용
  // KaKao api
  Future<String> getKakaomap(double lon, double lat) async {
    dynamic addressKey =
        "0b209f5c7458468469df5492074343bf"; // api kakao rest key
    // KaKao 좌표로 주소 변환 Rest Key
    final response = await dio.get(
      "https://dapi.kakao.com/v2/local/geo/coord2address.json",
      queryParameters: {"x": lon.toString(), "y": lat.toString()},
      options: Options(headers: {"Authorization": "KakaoAK $addressKey"}),
    );
    final doc = response.data['documents'] as List;
    if (doc.isEmpty) return "불가";
    final add = doc[0]["address"] as Map<String, dynamic>;
    return "${add['region_1depth_name']} " // 시
        "${add['region_2depth_name']} " // 구
        "${add['region_3depth_name']} " // 동
        "${add['main_address_no']}"; // 상세 주소
  } // get kakao map end

  // 내위치
  Future<bool> addressprint() async {
    bool EnableStart =
        await Geolocator.isLocationServiceEnabled(); // 스마트폰 gps 기능 확인 여부
    if (!EnableStart) {
      print("GPS 기능 안켜져있음");
      return Future.value(false); // 안켜져있으면 실패
    }
    ;
    // 권한 여부 확인
    LocationPermission locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied) {
      // 권한 요청 확인후 맞으면 팝업창 띄워줌 [ 허용 / 거부 ]
      locationPermission = await Geolocator.requestPermission();
      // 거부 누르면 false 로 반환
      if (locationPermission == LocationPermission.denied) {
        return Future.value(false);
      }
    } // 강력 팝업 : 거부 여러번 실행시 발동 { 다시는 묻지않기 }
    if (locationPermission == LocationPermission.deniedForever) {
      return Future.value(false);
    }
    Position position = await Geolocator.getCurrentPosition();
    dynamic x = position.longitude; // 경도
    dynamic y = position.latitude; // 위도

    String address = await getKakaomap(x, y);

    setState(() {
      addressCont.text = address;
      lon = x;
      lat = y;
      showMap = true;
      MapController.loadHtmlString(kakaoMap(lon!, lat!));
    });
    // 허용시 true
    return Future.value(true);
  }

  String kakaoMap(double lon, double lat) {
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Kakao Map</title>
</head>
<body>

<div id="map" style="width:100%;height:350px;"></div>

<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=caa87b2038ca1bb96deba339a07a78d5"></script>
<script>

// 지도를 표시할 div
var mapContainer = document.getElementById('map'),
    mapOption = {
        center: new kakao.maps.LatLng(${lat}, ${lon}), // GPS 위치로 지도 중심 이동
        level: 3
    };

var map = new kakao.maps.Map(mapContainer, mapOption);

// GPS 위치에 마커 표시
var marker = new kakao.maps.Marker({
    position: new kakao.maps.LatLng(${lat}, ${lon})
});
marker.setMap(map);

// 지도 클릭하면 마커 이동 + Flutter로 클릭 좌표 전달
kakao.maps.event.addListener(map, 'click', function(mouseEvent) {

    var latlng = mouseEvent.latLng;
    marker.setPosition(latlng);

    MapClick.postMessage(JSON.stringify({
        lat : latlng.getLat(),
        lon : latlng.getLng()
    }));
});

</script>
</body>
</html>
''';
  }

  Future<void> guest() async {
    final localsave = await SharedPreferences.getInstance();
    final token = localsave.getString("guestToken");
    try {
      final addressadd = addressCont.text.split(" ");
      final obj = {
        "gaddress1": addressadd[0],
        "gaddress2": addressadd[1],
        "gaddress3": addressadd[2],
      };
      final response = await dio.post(
        "http://10.0.2.2:8080/api/guest/detail",
        data: obj,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );
      final data = await response.data;
      print(data);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 상단 컬러바
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorBar(const Color(0xFF3DE0D2)),
              const SizedBox(width: 24),
              _colorBar(const Color(0xFF7FFFD4)),
              const SizedBox(width: 24),
              _colorBar(const Color(0xFFC5F6F6)),
            ],
          ),
          // 🔹 상단 텍스트
          SizedBox(height: 16),
          Text(
              "어디로 이사 오셨나요?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          Text(
              "새로운 동네 정보를 알려 드릴게요",
              style: TextStyle(fontSize: 17, color: Colors.grey),
          ),
          SizedBox(height: 24),

          Expanded(
            child: showMap && lon != null && lat != null
                ? WebViewWidget(controller: MapController)
                : Center(child: Text("내 위치 정보 조회하기")),
          ),
          SizedBox(height: 20),

          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: addressCont,
                  readOnly: true,
                  decoration: InputDecoration(labelText: "선택한 주소"),
                ),
              ),
            ],
          ),



          // 🔹 내 위치 버튼 (상단 유지)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 24) + const EdgeInsets.symmetric(horizontal: 24.0), // ⭐️ 좌우 패딩 추가,
            child: SizedBox( // ⭐️ 버튼 전체 크기 제어를 위해 SizedBox 추가
              width: double.infinity, // ⭐️ 너비를 최대로 확장
              child: OutlinedButton.icon( // OutlinedButton 사용
                onPressed: addressprint,
                icon: Icon(Icons.gps_fixed, color: _mainTealColor), // GPS 아이콘, 글자색과 동일한 청록색
                label: Text(
                  "내 위치로 주소 조회",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _mainTealColor, // ⭐️ 글자색: 다음 버튼의 배경색 (청록색)
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.transparent, // ⭐️ 배경색: 투명
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  side: BorderSide(color: _mainTealColor, width: 1.5), // ⭐️ 테두리색: 글자색과 동일
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),

          const Spacer(), // ⭐️ 하단 버튼을 아래로 밀어내기 위해 Spacer 추가

          // --- 🌟 하단 - 이전/다음 버튼 그룹 🌟 ---
          Padding(
            // ⭐️ 좌우 패딩과 하단 패딩 적용
            padding: const EdgeInsets.only(bottom: 50, top: 20) + const EdgeInsets.symmetric(horizontal: 24.0),

              // 🌟 "다음" 버튼 (Flex 3) 🌟
              child: ElevatedButton(
                onPressed: () async {
                  // 기존 '다음 단계' 버튼의 로직 유지
                  if (addressCont.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("주소 입력바람"),
                        duration: Duration(seconds: 2), // 알림 경과 시간창 2초
                      ),
                    );
                    return;
                  }
                  await guest();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OnboardingCategory()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),// 버튼 너비를 최대로 확장
                  // ⭐️ _nextButtonBgColor, _nextButtonTextColor 사용
                  backgroundColor: _nextButtonBgColor,
                  foregroundColor: _nextButtonTextColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("다음", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
          ),

          // --- 🌟 하단 버튼 그룹 종료 🌟 ---
        ],
      ),
    );
  }


  Widget _colorBar(Color color) {
    return Container(
      width: 60,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
