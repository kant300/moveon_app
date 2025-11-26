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

  @override
  void initState() {
    super.initState();

    MapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'MapClick',
        onMessageReceived: (msg) async {
          final gpsmap = jsonDecode(msg.message);
          double lat = gpsmap['lat'];
          double lon = gpsmap['lon'];

          String address = await getKakaomap(lon, lat);

          setState(() {
            addressCont.text = address;
          });
        },
      );
  }

  TextEditingController addressCont = TextEditingController();

  bool showMap = false;
  double? lat;
  double? lon;

  Future<String> getKakaomap(double lon, double lat) async {
    dynamic addressKey = "0b209f5c7458468469df5492074343bf";
    final response = await dio.get(
      "https://dapi.kakao.com/v2/local/geo/coord2address.json",
      queryParameters: {"x": lon.toString(), "y": lat.toString()},
      options: Options(headers: {"Authorization": "KakaoAK $addressKey"}),
    );
    final doc = response.data['documents'] as List;
    if (doc.isEmpty) return "불가";

    final add = doc[0]["address"] as Map<String, dynamic>;
    return "${add['region_1depth_name']} "
        "${add['region_2depth_name']} "
        "${add['region_3depth_name']} "
        "${add['main_address_no']}";
  }

  Future<bool> addressprint() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    Position position = await Geolocator.getCurrentPosition();
    double x = position.longitude;
    double y = position.latitude;

    String addr = await getKakaomap(x, y);

    setState(() {
      addressCont.text = addr;
      lon = x;
      lat = y;
      showMap = true;
      MapController.loadHtmlString(kakaoMap(lon!, lat!));
    });

    return true;
  }

  String kakaoMap(double lon, double lat) {
    return '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Kakao Map</title></head>
<body>

<div id="map" style="width:100%;height:350px;"></div>

<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=caa87b2038ca1bb96deba339a07a78d5"></script>
<script>

var mapContainer = document.getElementById('map'),
    mapOption = {
        center: new kakao.maps.LatLng(${lat}, ${lon}),
        level: 3
    };

var map = new kakao.maps.Map(mapContainer, mapOption);
var marker = new kakao.maps.Marker({
    position: new kakao.maps.LatLng(${lat}, ${lon})
});
marker.setMap(map);

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
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString("guestToken");
    try {
      final address = addressCont.text.split(" ");
      final obj = {
        "gaddress1": address[0],
        "gaddress2": address[1],
        "gaddress3": address[2],
      };

      await dio.post(
        "http://10.0.2.2:8080/api/guest/detail",
        data: obj,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainMint = Color(0xFF38D5C1);

    return Scaffold(
      backgroundColor: Color(0xFFF7FCFC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),

            // 🔹 진행바 (피그마 스타일)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _StepBar(active: true),
                SizedBox(width: 12),
                _StepBar(active: false),
                SizedBox(width: 12),
                _StepBar(active: false),
              ],
            ),

            const SizedBox(height: 25),

            // 🔹 타이틀 문구
            const Text(
              "어디로 이사 오셨나요?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "맞춤 정보를 제공해드릴게요",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 20),

            // 🔹 지도 선택 박스 (피그마처럼 큰 박스)
            GestureDetector(
              onTap: addressprint,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFE6F2F2)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.location_on,
                          size: 36, color: Color(0xFF3AC7C3)),
                      SizedBox(height: 8),
                      Text(
                        "지도에서 위치 선택",
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3AC7C3),
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 주소 입력 박스
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Color(0xFFE6F2F2)),
              ),
              child: TextField(
                controller: addressCont,
                readOnly: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "동네 이름이나 주소를 입력하세요",
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 지도 영역
            Expanded(
              child: showMap && lon != null && lat != null
                  ? WebViewWidget(controller: MapController)
                  : Center(
                child: Text(
                  "지도에서 위치를 선택해주세요",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),

            // 🔹 다음 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainMint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (addressCont.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("주소를 선택해주세요.")),
                      );
                      return;
                    }
                    await guest();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OnboardingCategory()),
                    );
                  },
                  child: const Text(
                    "다음",
                    style: TextStyle(fontSize: 17, color: Colors.white),
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

class _StepBar extends StatelessWidget {
  final bool active;

  const _StepBar({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 6,
      decoration: BoxDecoration(
        color: active ? Color(0xFF33D2C5) : Color(0xFFE2EEEE),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
