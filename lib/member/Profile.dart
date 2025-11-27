// lib/member/Profile.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

final dio = Dio();

class Profile extends StatefulWidget {
  StateProfile createState() => StateProfile();
}

class StateProfile extends State<Profile> {
  late WebViewController MapController;

  bool showMap = false;
  double? lat;
  double? lon;

  dynamic memberdate = {};

  TextEditingController mnameCont = TextEditingController();
  TextEditingController mphoneCont = TextEditingController();
  TextEditingController memailCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();

  // 🌿 메인 컬러
  final Color mainColor = Color(0xFF3DE0D2);

  @override
  void initState() {
    super.initState();
    getinfo();

    MapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('MapClick', onMessageReceived: (msg) async {
        final gpsmap = jsonDecode(msg.message);
        double lat = gpsmap['lat'];
        double lon = gpsmap['lon'];
        String address = await getKakaomap(lon, lat);

        setState(() {
          addressCont.text = address;
        });
      });
  }

  // ------------------------- 서버 정보 불러오기 -------------------------
  void getinfo() async {
    final localsave = await SharedPreferences.getInstance();
    final token = localsave.getString("logintoken");

    try {
      final response = await dio.get(
        "http://10.95.125.46:8080/api/member/info",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      final data = response.data;

      setState(() {
        memberdate = data;
        mnameCont.text = data['mname'];
        mphoneCont.text = data['mphone'];
        memailCont.text = data['memail'];
        addressCont.text =
        "${data['maddress1']} ${data['maddress2']} ${data['maddress3']}";
      });
    } catch (e) {
      print(e);
    }
  }

  // ------------------------- GPS 위치로 주소 가져오기 -------------------------
  Future<bool> addressprint() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    Position position = await Geolocator.getCurrentPosition();
    dynamic x = position.longitude;
    dynamic y = position.latitude;

    String address = await getKakaomap(x, y);

    setState(() {
      addressCont.text = address;
      lon = x;
      lat = y;
      showMap = true;
      MapController.loadHtmlString(kakaoMap(lon!, lat!));
    });

    return true;
  }

  // ------------------------- KakaoMap API -------------------------
  Future<String> getKakaomap(double lon, double lat) async {
    dynamic key = "0b209f5c7458468469df5492074343bf";

    final response = await dio.get(
      "https://dapi.kakao.com/v2/local/geo/coord2address.json",
      queryParameters: {"x": lon.toString(), "y": lat.toString()},
      options: Options(headers: {"Authorization": "KakaoAK $key"}),
    );

    final doc = response.data['documents'] as List;
    if (doc.isEmpty) return "불가";
    final add = doc[0]["address"];

    return "${add['region_1depth_name']} "
        "${add['region_2depth_name']} "
        "${add['region_3depth_name']} "
        "${add['main_address_no']}";
  }

  // ------------------------- 프로필 업데이트 -------------------------
  void profileupdate() async {
    final address = addressCont.text.split(" ");
    final obj = {
      "mid": memberdate['mid'],
      "mname": mnameCont.text,
      "mphone": mphoneCont.text,
      "memail": memailCont.text,
      "maddress1": address[0],
      "maddress2": address[1],
      "maddress3": address.sublist(2).join(" "),
    };

    try {
      final response =
      await dio.put("http://10.95.125.46:8080/api/member/update", data: obj);
      final data = response.data;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text("프로필 수정 완료"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: Text("확인"),
            ),
          ],
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  // ------------------------- Kakao 지도 HTML -------------------------
  String kakaoMap(double lon, double lat) {
    return '''
<html>
  <body>
    <div id="map" style="width:100%; height:350px;"></div>
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=caa87b2038ca1bb96deba339a07a78d5"></script>
    <script>
      var map = new kakao.maps.Map(document.getElementById('map'), {
        center: new kakao.maps.LatLng(${lat}, ${lon}),
        level: 3
      });

      var marker = new kakao.maps.Marker({
        position: new kakao.maps.LatLng(${lat}, ${lon})
      });
      marker.setMap(map);

      kakao.maps.event.addListener(map, 'click', function(mouseEvent) {
        var latlng = mouseEvent.latLng;
        marker.setPosition(latlng);

        MapClick.postMessage(JSON.stringify({
          lat: latlng.getLat(),
          lon: latlng.getLng()
        }));
      });
    </script>
  </body>
</html>
''';
  }

  // ------------------------- UI 디자인 -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("프로필 수정"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ------------------- 프로필 수정 카드 -------------------
            _inputCard(
              title: "이름",
              child: TextField(
                controller: mnameCont,
                decoration: _inputDeco("이름 입력"),
              ),
            ),

            _inputCard(
              title: "전화번호",
              child: TextField(
                controller: mphoneCont,
                decoration: _inputDeco("전화번호 입력"),
              ),
            ),

            _inputCard(
              title: "이메일",
              child: TextField(
                controller: memailCont,
                decoration: _inputDeco("Email 입력"),
              ),
            ),

            _inputCard(
              title: "주소",
              child: TextField(
                controller: addressCont,
                readOnly: true,
                decoration: _inputDeco("주소 선택"),
              ),
            ),

            // ------------------- 위치 버튼 -------------------
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addressprint,
                icon: Icon(Icons.my_location, color: Colors.white),
                label: Text("내 위치로 주소 가져오기"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // ------------------- 지도 출력 -------------------
            if (showMap)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: WebViewWidget(controller: MapController),
                  ),
                ),
              ),

            SizedBox(height: 30),

            // ------------------- 저장 버튼 -------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: profileupdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "변경사항 저장",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- 재사용 가능한 카드 박스 ----------------------
  Widget _inputCard({required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // ---------------------- 공통 Input 디자인 ----------------------
  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder:
      OutlineInputBorder(borderSide: BorderSide(color: mainColor, width: 2)),
    );
  }
}
