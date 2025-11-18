import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moveon_app/screens/onboarding/OnboardingCategory.dart';
import 'package:webview_flutter/webview_flutter.dart';

final dio=Dio();

class OnboardingAddress extends StatefulWidget {
  const OnboardingAddress({super.key});

  @override
  OnboardingAddressState createState() => OnboardingAddressState();
}

class OnboardingAddressState extends State<OnboardingAddress> {

  TextEditingController addressCont = TextEditingController();

  bool showMap = false;
  double? lat ; // WebView 사용
  double? lon ; // WebView 사용
  // KaKao api
  Future<String> getKakaomap(double lon , double lat) async{
    dynamic addressKey = "0b209f5c7458468469df5492074343bf"; // api kakao rest key
    // KaKao 좌표로 주소 변환 Rest Key
    final response = await dio.get("https://dapi.kakao.com/v2/local/geo/coord2address.json" ,
      queryParameters: {
        "x" : lon.toString(),
        "y" : lat.toString(),
      },
      options: Options(headers: {"Authorization" : "KakaoAK $addressKey"},
      ),
    );
    final doc = response.data['documents'] as List;
    if(doc.isEmpty) return "불가";
    final add = doc[0]["address"] as Map<String , dynamic> ;
    return "${add['region_1depth_name']} " // 시
        "${add['region_2depth_name']} " // 구
        "${add['region_3depth_name']} " // 동
        "${add['main_address_no']}" ; // 상세 주소
  } // get kakao map end

  // 내위치
  Future<bool> addressprint() async{
    bool EnableStart = await Geolocator.isLocationServiceEnabled(); // 스마트폰 gps 기능 확인 여부
    if(!EnableStart) {
      print("GPS 기능 안켜져있음");
      return Future.value(false); // 안켜져있으면 실패
    };
    // 권한 여부 확인
    LocationPermission locationPermission = await Geolocator.checkPermission();

    if(locationPermission == LocationPermission.denied) {
      // 권한 요청 확인후 맞으면 팝업창 띄워줌 [ 허용 / 거부 ]
      locationPermission = await Geolocator.requestPermission();
      // 거부 누르면 false 로 반환
      if (locationPermission == LocationPermission.denied) {
        return Future.value(false);
      }
    } // 강력 팝업 : 거부 여러번 실행시 발동 { 다시는 묻지않기 }
    if(locationPermission == LocationPermission.deniedForever){
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
    });
    // 허용시 true
    return Future.value(true);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("주소 확인"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // 🔹 상단 텍스트
          SizedBox(height: 20),
          Text("어디로 이사 오셨나요?", style: TextStyle(fontSize: 18)),
          Text("새로운 동네 정보를 알려 드릴게요", style: TextStyle(fontSize: 14)),
          SizedBox(height: 16),

          // 🔹 내 위치 버튼 (상단 유지)
          ElevatedButton(
            onPressed: addressprint,
            child: Text("내 위치 조회"),
          ),

          SizedBox(height: 16),

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

          SizedBox(height: 10),

          // 🔹 지도 영역 (아래로 내림)
          Expanded(
            child: showMap && lat != null && lon != null
                ? WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(
                  Uri.parse(
                    "https://map.kakao.com/link/map/MyLocation,$lat,$lon",
                  ),
                ),
            )
                : Center(child: Text("내위치를 조회하면 지도가 표시됩니다.")),
          ),

          // 🔹 하단 - 다음 버튼
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnboardingCategory(),
                  ),
                );
              },
              child: const Text("다음 단계"),
            ),
          ),
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
