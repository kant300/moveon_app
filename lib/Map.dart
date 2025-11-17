import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoMap extends StatefulWidget {
  const KakaoMap({super.key});

  @override
  KakaoMapState createState() => KakaoMapState();
}

class KakaoMapState extends State<KakaoMap> {
  late final WebViewController _controller;
  double? lat;
  double? lng;

  final String kakaoJsKey = '9eb4f86b6155c2fa2f5dac204d2cdb35';

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
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=$kakaoJsKey&libraries=services,clusterer"></script>
  </head>
  <body style="margin:0;">
    <div id="map" style="width:100%;height:100vh;"></div>
    <script>
      var mapContainer = document.getElementById('map');
      var mapOption = {
        center: new kakao.maps.LatLng(37.5665, 126.9780),
        level: 3
      };
      var map = new kakao.maps.Map(mapContainer, mapOption);

      // 현재 본인 위치
      var marker = new kakao.maps.Marker({
        position: new kakao.maps.LatLng(37.5665, 126.9780)
      });
      marker.setMap(map);
      
      // 마커 클러스터러를 생성합니다 
      var clusterer = new kakao.maps.MarkerClusterer({
          map: map, // 마커들을 클러스터로 관리하고 표시할 지도 객체 
          averageCenter: true, // 클러스터에 포함된 마커들의 평균 위치를 클러스터 마커 위치로 설정 
          minLevel: 4 // 클러스터 할 최소 지도 레벨 
      });

      // ✅ Flutter에서 여러 마커 데이터를 받을 함수
      window.addMarkers = function(markerList, category) {
        // ✅ 기존 마커 제거
        clusterer.clear();
        var markers = [];
        
        // ✅ 기존 인포윈도우 닫기
        if (window.infowindow && window.infowindow.close) {
          window.infowindow.close();
        }
        window.infowindow = new kakao.maps.InfoWindow();
    
        for (var i = 0; i < markerList.length; i++) {
          (function(m) { // 클로저로 i값 고정
            if (category == "localParking") { // 공영주차장은 데이터 형식이 다름
              var markerPosition = new kakao.maps.LatLng(m["lat"], m["long"]);
            } else {
              var markerPosition = new kakao.maps.LatLng(m["위도"], m["경도"]);
            }
            
            // 마커 생성
            var marker = new kakao.maps.Marker({
              position: markerPosition
            });
            markers.push(marker);
            
            // ✅ 마커 클릭 시 인포윈도우 열기
            kakao.maps.event.addListener(marker, 'click', function() {
              // category 에 따라 infoWindow 데이터 삽입
              if (category == "clothingBin") { // 의류수거함
                window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
                  m["도로명 주소"] +
                '</div>');
              } else if (category == "government") { // 관공서
                window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' + 
                  '<div>' + m["시설명"] + '</div>' +
                  '<div>' + m["주소"] + '</div>' +
                  '<div>' + m["전화번호"] + '</div>' +
                '</div>');
              } else if (category == "night") { // 심야약국/병원
                window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' + 
                  '<div>' + m["시설명"] + '</div>' +
                  '<div>' + m["주소"] + '</div>' +
                  '<div>' + m["전화번호"] + '</div>' +
                '</div>');
              } else if (category == "shelter") { // 대피소
                window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
                  m["시설명"] +
                '</div>');
              } else if (category == "restroom") { // 공중화장실
                window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' + 
                  '<div>' + m["화장실명"] + '</div>' +
                  '<div>' + m["소재지도로명주소"] + '</div>' +
                  '<div>관리기관: ' + m["관리기관명"] + ' ' + m["전화번호"] + '</div>' +
                  '<div>개방시간: ' + m["개방시간상세"] + '</div>' +
                '</div>');
              } else if (category == "subwayLift") { // 지하철/승강기
                window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' + 
                  '<div>' + m["역사"] + '역</div>' +
                  '<div>' + m["호기"] + '호 ' + m["장비"] + '</div>' +
                  '<div>' + m["상태"] + '</div>' +
                '</div>');
              } else if (category == "subwaySchedule") { // 지하철/배차
                window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
                  '<div><strong>' + m["역사명"] + '역 배차 정보</strong></div>' +
                  (m["prevStation"] == "none"
                    ? ''
                    : (m["time_first_1"] <= 0 || m["time_second_1"] <= 0
                        ? '<div>' + m["prevStation"] + '역 방면: 배차 정보가 없습니다.</div>'
                        : '<div>' + m["prevStation"] + '역 방면: ' + m["time_first_1"] + '분 후 도착, ' + m["time_second_1"] + '분 후 도착</div>'
                      )
                  ) +
                  (m["nextStation"] == "none"
                    ? ''
                    : (m["time_first_2"] <= 0 || m["time_second_2"] <= 0
                        ? '<div>' + m["nextStation"] + '역 방면: 배차 정보가 없습니다.</div>'
                        : '<div>' + m["nextStation"] + '역 방면: ' + m["time_first_2"] + '분 후 도착, ' + m["time_second_2"] + '분 후 도착</div>'
                      )
                  ) +
                '</div>');
              } else if (category == "wheelchairCharger") { // 전동휠체어
                window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' + 
                  '<div>' + m["시설명"] + '</div>' +
                  '<div>' + m["소재지도로명주소"] + '</div>' +
                  '<div>평일: ' + m["평일운영시작시각"] + "~" + m["평일운영종료시각"] + '</div>' +
                  '<div>' + m["관리기관명"] + '</div>' +
                '</div>');
              } else if (category == "localParking") { // 공영주차장
                window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
                  m["name"] +
                '</div>');
              } else if (category == "gas") {
                window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' + 
                  '<div>' + m["업소명"] + '</div>' +
                  '<div>' + m["소재지"] + '</div>' +
                  '<div>' + m["전화번호"] + '</div>' +
                '</div>');
              }
              
              window.infowindow.open(map, marker);
            });
          })(markerList[i]);
        }
        // 클러스터러에 마커들을 추가합니다
        clusterer.addMarkers(markers);
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
      } else if (category == "subwayLift") { // 지하철/승강기
        url = "http://192.168.40.28:8080/transport/lift";
        // key: 역사, 장비, 호기, 위도, 경도, 상태
      } else if (category == "subwaySchedule") { // 지하철/배차
        url = "http://192.168.40.28:8080/transport/location";
        // key: 역사명, 위도, 경도
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
      print(data);

      // 지하철/배차는 배차 시각 정보를 추가해야 함
      if (category == "subwaySchedule") {
        // 현재 시간 today 를 int 로 변환
        // UTC -> KST 시간으로 변경 (9시간 추가)
        final today = DateTime.now().add(Duration(hours: 9));
        // print(today);
        final now = today.hour * 60 + today.minute;
        // print(now);

        // 시간 → "n분 후 도착" 또는 "배차 정보 없음"
        int formatArrival(String? time) {
          if (time == null || time.isEmpty) return 0;

          // 매개변수 time 을 int 로 변환
          final parts = time.split(":").map(int.parse).toList();
          final currentTime = parts[0] * 60 + parts[1];
          // print(currentTime);

          // time 과 today 를 비교해서 시간 차이 diff ('n분 후' 형식) 알아내기
          final diff = currentTime - now;
          return diff < 0 ? 0 : diff;
        }

        for (int i=0; i<data.length; i++) {
          dynamic stationName = data[i]["역사명"];
          // 이전 역, 다음 역 이름 삽입
          data[i]["prevStation"] = i > 0 ? data[i-1]["역사명"] : "none";
          data[i]["nextStation"] = i < data.length-1 ? data[i+1]["역사명"] : "none";

          final responseTime = await Dio().get("http://192.168.40.28:8080/transport/schedule", queryParameters: {"station_name": stationName});
          // [LocalTime, LocalTime]

          if (responseTime.statusCode == 200 && responseTime.data is List && responseTime.data.length >= 2) {
            final prevTimes = responseTime.data[0];
            final nextTimes = responseTime.data[1];

            // n분 후 형식으로 시간 파싱하여 삽입
            data[i]["time_first_1"] = formatArrival(prevTimes[0]);
            data[i]["time_second_1"] = formatArrival(prevTimes[1]);
            data[i]["time_first_2"] = formatArrival(nextTimes[0]);
            data[i]["time_second_2"] = formatArrival(nextTimes[1]);
          } else {
            data[i]["time_first_1"] = 0;
            data[i]["time_second_1"] = 0;
            data[i]["time_first_2"] = 0;
            data[i]["time_second_2"] = 0;
          }
        }
      }

      // 의류수거함은 데이터 형식이 다름
      if (category == "clothingBin") {
        data = data["data"];
      }
      // 최종 데이터 확인
      // print( data );

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
      appBar: AppBar(title: const Center(child: Text('통합 지도'),)),
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
                  heroTag: "clothingBin",
                  onPressed: () async => { await _fetchAndShowMarkers("clothingBin") },
                  child: Text("의류수거함"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "government",
                  onPressed: () async => { await _fetchAndShowMarkers("government") },
                  child: Text("관공서"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "night",
                  onPressed: () async => { await _fetchAndShowMarkers("night") },
                  child: Text("약국/병원"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "shelter",
                  onPressed: () async => { await _fetchAndShowMarkers("shelter") },
                  child: Text("대피소"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "restroom",
                  onPressed: () async => { await _fetchAndShowMarkers("restroom") },
                  child: Text("공중화장실"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "subwayLift",
                  onPressed: () async => { await _fetchAndShowMarkers("subwayLift") },
                  child: Text("지하철/승강기"),
                ),
                FloatingActionButton.small(
                  heroTag: "subwaySchedule",
                  onPressed: () async => { await _fetchAndShowMarkers("subwaySchedule") },
                  child: Text("지하철/배차"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "wheelchairCharger",
                  onPressed: () async => { await _fetchAndShowMarkers("wheelchairCharger") },
                  child: Text("전동휠체어"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "localParking",
                  onPressed: () async => { await _fetchAndShowMarkers("localParking") },
                  child: Text("공영주차장"),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "gas",
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