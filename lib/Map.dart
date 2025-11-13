import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: KakaoMap(),
  ));
}

class KakaoMap extends StatefulWidget {
  const KakaoMap({super.key});

  @override
  KakaoMapState createState() => KakaoMapState();
}

class KakaoMapState extends State<KakaoMap> {
  late final WebViewController _controller;
  double? lat;
  double? lng;

  final String kakaoJsKey = '1ac4a57d8a5927d34020a891fcdbbcbd';

  @override
  void initState() {
    super.initState();

    // ✅ 카카오지도 HTML
    final html =
        '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=$kakaoJsKey"></script>
  </head>
  <body style="margin:0;">
    <div id="map" style="width:100%;height:100vh;"></div>
    <script>
      var mapContainer = document.getElementById('map');
      var mapOption = {
        center: new kakao.maps.LatLng(37.5665, 126.9780),
        level: 4
      };
      var map = new kakao.maps.Map(mapContainer, mapOption);

      var marker = new kakao.maps.Marker({
        position: new kakao.maps.LatLng(37.5665, 126.9780)
      });
      marker.setMap(map);

      // ✅ Flutter에서 여러 마커 데이터를 받을 함수
      window.addMarkers = function(markerList, category) {
        // ✅ 기존 마커 제거
        window.markers = window.markers || [];
        for (var i = 0; i < window.markers.length; i++) {
          window.markers[i].setMap(null);
        }
        window.markers = [];

        var infowindow = new kakao.maps.InfoWindow(); // 하나만 유지
    
        for (var i = 0; i < markerList.length; i++) {
          (function(m) { // 클로저로 i값 고정
            var markerPosition = new kakao.maps.LatLng(m["위도"], m["경도"]);
            var marker = new kakao.maps.Marker({ position: markerPosition });
            marker.setMap(map);
            window.markers.push(marker);
            
            // ✅ 마커 클릭 시 인포윈도우 열기
            kakao.maps.event.addListener(marker, 'click', function() {
              // category 에 따라 infoWindow 데이터 삽입
              if (category == "clothingBin") { // 의류수거함
                infowindow.setContent('<div style="padding:5px;">' +
                  m["도로명 주소"] +
                '</div>');
              } else if (category == "government") { // 관공서
                infowindow.setContent('<div style="padding:5px;">' + 
                  '<div>' + m["시설명"] + '</div>' +
                  '<div>' + m["주소"] + '</div>' +
                  '<div>' + m["전화번호"] + '</div>' +
                '</div>');
              } else if (category == "night") { // 심야약국/병원
                
              } else if (category == "shelter") { // 대피소
                
              } else if (category == "restroom") { // 공중화장실
                
              } else if (category == "subway") { // 지하철 TODO
                
              } else if (category == "wheelchairCharger") { // 전동휠체어
                
              } else if (category == "localParking") { // 공영주차장
                
              } else if (category == "gas") {
                
              }
              infowindow.open(map, marker);
            });
          })(markerList[i]);
        }
      }
      
      // ✅ 지도 확대 / 축소 함수 추가
      function zoomIn() {
        map.setLevel(map.getLevel() - 1); // 레벨 1 감소 = 확대
      }
      function zoomOut() {
        map.setLevel(map.getLevel() + 1); // 레벨 1 증가 = 축소
      }
  
    </script>
  </body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.dataFromString(
          html,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ),
      );

    // 초기 위치 + 마커 로드
    _initLocation();
  }

  // ✅ 위치 권한 요청 및 현재 위치 가져오기
  Future<void> _initLocation() async {
    if (await Permission.location.request().isGranted) {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      lat = pos.latitude;
      lng = pos.longitude;

      // 지도 이동
      _moveToMyLocation();

      // ✅ 서버에서 마커 데이터 가져오기 (현재 의류수거함을 기본 데이터로 설정)
      await _fetchAndShowMarkers("clothingBin");
    } else {
      await openAppSettings();
    }
  }

  // ✅ Flutter → JS로 지도 중심 이동
  void _moveToMyLocation() {
    if (lat != null && lng != null) {
      final js =
          '''
        var moveLatLon = new kakao.maps.LatLng($lat, $lng);
        map.panTo(moveLatLon);
        marker.setPosition(moveLatLon);
      ''';
      _controller.runJavaScript(js);
    }
  }

  // ✅ 서버에서 마커 데이터 가져와 JS로 전달
  Future<void> _fetchAndShowMarkers(String category) async {
    try {
      String url = '';
      dynamic data = [];
      if (category == "clothingBin") { // 의류수거함
        url = "https://api.odcloud.kr/api/15141554/v1/uddi:574fcc84-bcb8-4f09-9588-9b820731bf19?page=1&perPage=368&serviceKey=lxvZMQzViYP1QmBRI9MrdDw5ZmsblpCAd5iEKcTRES4ZcynJhQxzAuydpechK3TJCn43OJmweWMoYZ10aspdgQ%3D%3D";
        // key: 경도, 관리번호, 도로명 주소, 연번, 위도
      } else if (category == "government") { // 관공서
        url = "http://192.168.40.28:8080/living/gov";
        // key: 유형, 시설명, 주소, 전화번호, 경도, 위도
      } else if (category == "night") { // 심야약국/병원
        url = "http://192.168.40.28:8080/living/medical";
        // key: 유형, 시설명, 주소, 전화번호, 경도, 위도
      } else if (category == "shelter") { // 대피소
        url = "http://192.168.40.28:8080/safety/shelter";
        // key: 시설명, 위도, 경도
      } else if (category == "restroom") { // 공중화장실
        url = "http://192.168.40.28:8080/safety/toilet";
        // key: 화장실명, 소재지도로명주소, 관리기관명, 전화번호, 개방시간상세, 위도, 경도
      } else if (category == "subway") { // 지하철 TODO
        // getLiftData
        url = "http://192.168.40.28:8080/transport/lift";
        // key: 역사, 장비, 호기, 위도, 경도, 상태

        // getStationLocationData
        url = "http://192.168.40.28:8080/transport/location";
        // key: 역사명, 위도, 경도

        // getScheduleData
        "http://192.168.40.28:8080/transport/location";
        // [LocalTime, LocalTime]
      } else if (category == "wheelchairCharger") { // 전동휠체어
        url = "http://192.168.40.28:8080/api/chargers/all";
        // key: 시설명, 소재지도로명주소, 위도, 경도, 평일운영시작시각, 평일운영종료시각, 관리기관명
      } else if (category == "localParking") { // 공영주차장
        url = "http://192.168.40.28:8080/transport/parking";
        // key: name, long, lat (시설명, 경도, 위도)
      } else if (category == "gas") {
        url = "http://192.168.40.28:8080/transport/gas";
        // key: 업소명, 소재지, 위도, 경도, 전화번호
      }
      final response = await Dio().get(url);
      data = response.data;

      if (category == "clothingBin") { // 의류수거함은 데이터 형식이 다름
        data = data["data"];
      }
      print( data );

      //final data = response.data;
      final jsData = jsonEncode(data);
      final jsCategory = jsonEncode(category);
      final js = "addMarkers($jsData, $jsCategory);";
      _controller.runJavaScript(js);
    } catch (e) {
      print("마커 데이터 불러오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('동인천역 주변 지도')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          // 오른쪽 하단 확대/축소 버튼
          Positioned(
            right: 10,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoomIn",
                  onPressed: () => _controller.runJavaScript("zoomIn();"),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "zoomOut",
                  onPressed: () => _controller.runJavaScript("zoomOut();"),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // 왼쪽 상단 카테고리 버튼
          Positioned(
            left: 10,
            top: 100,
            child: Column(
              children: [
                FloatingActionButton.small(
                  onPressed: () async => { await _fetchAndShowMarkers("clothingBin") },
                  child: Text("의류수거함"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  onPressed: () async => { await _fetchAndShowMarkers("government") },
                  child: Text("관공서"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  onPressed: () async => { await _fetchAndShowMarkers("night") },
                  child: Text("약국/병원"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  onPressed: () async => { await _fetchAndShowMarkers("shelter") },
                  child: Text("대피소"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  onPressed: () async => { await _fetchAndShowMarkers("restroom") },
                  child: Text("공중화장실"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  onPressed: () async => { await _fetchAndShowMarkers("subway") },
                  child: Text("지하철"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  onPressed: () async => { await _fetchAndShowMarkers("wheelchairCharger") },
                  child: Text("전동휠체어"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  onPressed: () async => { await _fetchAndShowMarkers("localParking") },
                  child: Text("공영주차장"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  onPressed: () async => { await _fetchAndShowMarkers("gas") },
                  child: Text("주유소"),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _initLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}