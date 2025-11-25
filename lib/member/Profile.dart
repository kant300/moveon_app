// lib/member/Profile.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moveon_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

final dio=Dio();

class Profile extends StatefulWidget {
  StateProfile createState() => StateProfile();
}

class StateProfile extends State<Profile> {
  late WebViewController MapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfo();

    MapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
          'MapClick',
          onMessageReceived: (msg) async {
            final gpsmap = jsonDecode(msg.message);
            double lat = gpsmap['lat'];
            double lon = gpsmap['lon'];
            print("좌포 전달 ${msg.message}");
            String address = await getKakaomap(lon, lat);

            setState(() {
              addressCont.text =
                  address; // lon , lat / 윋 ㅗ경도 주소 address 로 받아서  input text에 넣어줌
            });
          },
      );
  }

  bool showMap = false;
  double? lat; // WebView 사용
  double? lon; // WebView 사용

  dynamic memberdate = {};
  void getinfo() async{ // 정보 호출
      final localsave = await SharedPreferences.getInstance();
      final token = await localsave.getString("logintoken");
      try{
      final response = await dio.get("http://10.0.2.2:8080/api/member/info",
      options: Options(headers: { "Authorization" : "Bearer $token"},),
      );
      final data = await response.data;
      print(data);
      setState(() {
        memberdate=data;
        mnameCont.text = data['mname'];
        mphoneCont.text = data['mphone'];
        memailCont.text = data['memail'];
        addressCont.text = "${data['maddress1']} ${data['maddress2']} ${data['maddress3']}";
      });
    }catch(e) {print(e); }
  }

  TextEditingController mnameCont = TextEditingController();
  TextEditingController mphoneCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController memailCont = TextEditingController();

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

  // 내위치
  Future<bool> addressprint() async {
    bool EnableStart =
    await Geolocator.isLocationServiceEnabled(); // 스마트폰 gps 기능 확인 여부
    if (!EnableStart) {
      print("GPS 기능 안켜져있음");
      return Future.value(false); // 안켜져있으면 실패
    }
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

  // // 내위치
  // Future<bool> addressprint() async{
  //   bool EnableStart = await Geolocator.isLocationServiceEnabled(); // 스마트폰 gps 기능 확인 여부
  //   if(!EnableStart) {
  //     print("GPS 기능 안켜져있음");
  //     return Future.value(false); // 안켜져있으면 실패
  //   };
  //   // 권한 여부 확인
  //   LocationPermission locationPermission = await Geolocator.checkPermission();
  //
  //     if(locationPermission == LocationPermission.denied) {
  //       // 권한 요청 확인후 맞으면 팝업창 띄워줌 [ 허용 / 거부 ]
  //       locationPermission = await Geolocator.requestPermission();
  //       // 거부 누르면 false 로 반환
  //       if (locationPermission == LocationPermission.denied) {
  //         return Future.value(false);
  //       }
  //     } // 강력 팝업 : 거부 여러번 실행시 발동 { 다시는 묻지않기 }
  //     if(locationPermission == LocationPermission.deniedForever){
  //       return Future.value(false);
  //     }
  //     Position position = await Geolocator.getCurrentPosition();
  //     dynamic x = position.longitude; // 경도
  //     dynamic y = position.latitude; // 위도
  //
  //     String address = await getKakaomap(x, y);
  //
  //     setState(() {
  //       addressCont.text = address;
  //     });
  //
  //     // 허용시 true
  //     return Future.value(true);
  // }

  void profileupdate() async{
    try{
      final address = addressCont.text.split(" ");
      final obj = {
        "mid" : memberdate['mid'] ,
        "mname" : mnameCont.text,
        "mphone" : mphoneCont.text,
        "memail" : memailCont.text,
        "maddress1" : address[0],
        "maddress2" : address[1],
        "maddress3" : address[2] + " " +address[3],
      };
      final response = await dio.put("http://10.0.2.2:8080/api/member/update" , data: obj);
      final data = await response.data;
      print(data);

      showDialog(context: context, builder: (context) {
        return AlertDialog(
          content: Text("프로필 수정 완료"),
          actions: [
            TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context , true); },
            child: Text("확인"),
            ),
          ],
        );
      });
    }catch(e) { print(e); }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("프로필 수정"),
          leading: IconButton( icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context ,true);},
          ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름/폰/메일
            TextField(controller: mnameCont , decoration: InputDecoration(labelText: "이름 수정?"),),
            TextField(controller: mphoneCont , decoration: InputDecoration(labelText: "폰?"),),
            TextField(controller: memailCont , decoration: InputDecoration(labelText: " 이메일?"),),

            // 주소 1개만 표시 (readOnly)
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: addressCont,
                readOnly: true,
                decoration: InputDecoration(labelText: "선택한 주소"),
              ),
            ),

            // 내 위치 버튼
            OutlinedButton(
              onPressed: addressprint,
              child: Text("내위치 조회"),
            ),

            // 지도 출력 (WebView)
            if (showMap && lon != null && lat != null)
              Container(
                height: 300,
                margin: EdgeInsets.symmetric(vertical: 16),
                child: WebViewWidget(controller: MapController),
              ),

            // 저장 버튼
            TextButton(
              onPressed: profileupdate,
              child: Text("변경"),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
