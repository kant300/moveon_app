// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class KakaoMap extends StatefulWidget {
//   const KakaoMap({super.key});
//
//   @override
//   KakaoMapState createState() => KakaoMapState();
// }
//
// class KakaoMapState extends State<KakaoMap> {
//   late final WebViewController _controller;
//   double? lat;
//   double? lng;
//   // ★ 추가: 지역 필터링을 위한 변수
//   String? selectedSido;
//   String? selectedSigungu;
//   // ★ 추가: 지역 필터링용 데이터 (인천 지역 시군구)
//   final List<String> sidoList = [ '인천' ];
//   final Map<String, List<String>> sigunguMap = {
//     '인천': ['강화군','계양구','남동구','동구', '미추홀구','부평구', '서구','연수구','옹진군','중구'],
//   };
//
//   final String kakaoJsKey = '9eb4f86b6155c2fa2f5dac204d2cdb35';
//   final String serverBaseUrl = 'http://192.168.40.61:8080';
//
//   @override
//   void initState() {
//     super.initState();
//
//     /// ============================
//     /// 1) Kakao Map HTML
//     /// (기존 코드와 동일)
//     /// ============================
//     final html =
//     '''
// <!DOCTYPE html>
// <html>
//   <head>
//     <meta charset="utf-8" />
//     <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
//     <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=$kakaoJsKey&libraries=services,clusterer"></script>
//   </head>
//   <body style="margin:0;">
//     <div id="map" style="width:100%;height:100vh;"></div>
//     <script>
//       var mapContainer = document.getElementById('map');
//       var mapOption = {
//         center: new kakao.maps.LatLng(37.5665, 126.9780),
//         level: 3
//       };
//       var map = new kakao.maps.Map(mapContainer, mapOption);
//
//       // 현재 본인 위치
//       var marker = new kakao.maps.Marker({
//         position: new kakao.maps.LatLng(37.5665, 126.9780)
//       });
//       marker.setMap(map);
//       // 내 위치 마커 클릭 → Flutter 전달
//       kakao.maps.event.addListener(marker, 'click', function() {
//         if (window.flutterChannel) {
//           window.flutterChannel.postMessage("myLocationClick");
//         }
//       });
//
//       // 마커 클러스터러를 생성합니다
//       var clusterer = new kakao.maps.MarkerClusterer({
//           map: map, // 마커들을 클러스터로 관리하고 표시할 지도 객체
//           averageCenter: true, // 클러스터에 포함된 마커들의 평균 위치를 클러스터 마커 위치로 설정
//           minLevel: 4 // 클러스터 할 최소 지도 레벨
//       });
//
//       // ✅ Flutter에서 여러 마커 데이터를 받을 함수
//       window.addMarkers = function(markerList, category) {
//         // ... (마커 생성 및 인포윈도우 로직 생략)
//         // ✅ 기존 마커 제거
//         clusterer.clear();
//         var markers = [];
//         // ✅ 기존 인포윈도우 닫기
//         if (window.infowindow && window.infowindow.close) {
//           window.infowindow.close();
//         }
//         window.infowindow = new kakao.maps.InfoWindow();
//
//         for (var i = 0; i < markerList.length; i++) {
//           (function(m) {
//             var markerPosition = new kakao.maps.LatLng(m["위도"] || m["lat"], m["경도"] || m["long"]);
//             var marker = new kakao.maps.Marker({
//               position: markerPosition
//             });
//             markers.push(marker);
//
//             kakao.maps.event.addListener(marker, 'click', function() {
//               window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">마커 클릭 정보</div>');
//               window.infowindow.open(map, marker);
//             });
//           })(markerList[i]);
//         }
//         clusterer.addMarkers(markers);
//       }
//
//
//       // ✅ 지도 확대 / 축소 함수 추가
//       function zoomIn() {
//         map.setLevel(map.getLevel() - 1);
//       }
//       function zoomOut() {
//         map.setLevel(map.getLevel() + 1);
//       }
//
//     </script>
//   </body>
// </html>
// ''';
//
//     _controller = WebViewController()
//       ..addJavaScriptChannel(
//         'flutterChannel',
//         onMessageReceived: (msg) {
//           if (msg.message == "myLocationClick") {
//             _loadCrimeInfo(lat, lng);
//           }
//         },
//       )
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(
//         Uri.dataFromString(
//           html,
//           mimeType: 'text/html',
//           encoding: Encoding.getByName('utf-8'),
//         ),
//       );
//
//     _initLocation();
//   }
//
//   // ✅ 위치 권한 요청 및 현재 위치 가져오기
//   Future<void> _initLocation() async {
//     if (await Permission.location.request().isGranted) {
//       Position pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       lat = pos.latitude;
//       lng = pos.longitude;
//
//       // ★ 초기 시도/시군구 설정 (인천/부평구로 초기화)
//       selectedSido = '인천';
//       selectedSigungu = '부평구';
//
//       _moveToMyLocation();
//       await _fetchAndShowMarkers("clothingBin");
//       setState(() {});
//     } else {
//       await openAppSettings();
//     }
//   }
//
//   // 서버 REST 호출해서 성범죄자 통계 가져오기 (내 위치 마커 클릭 시)
//   Future<void> _loadCrimeInfo(double? clickLat, double? clickLng) async {
//     if (clickLat == null || clickLng == null) return;
//
//     try {
//       final res = await Dio().get(
//         "$serverBaseUrl/api/sexcrime/near",
//         queryParameters: {"lat": clickLat, "lng": clickLng},
//       );
//       _showCrimeModal(res.data);
//     } catch (e) {
//       print("성범죄자 통계 불러오기 오류: $e");
//     }
//   }
//
//   // ★ 추가: 지역 필터링 기반 성범죄자 통계 가져오기
//   Future<void> _filterCrimeInfo(String sido, String sigungu) async {
//     try {
//       final res = await Dio().get(
//         "$serverBaseUrl/safety/sexcrime/count",
//         queryParameters: {"sido": sido, "sigungu": sigungu, "dong": ""},
//       );
//
//       // 지역 정보를 함께 구성: 시군구 단위 필터링 결과임을 표시
//       final data = {
//         "region": {"sido": sido, "sigungu": sigungu, "dong": ""}, // 읍면동은 비워둠
//         "counts": res.data
//       };
//
//       _showCrimeModal(data);
//     } catch (e) {
//       print("지역 필터링 통계 불러오기 오류: $e");
//     }
//   }
//
//   // ★ 모달로 표시 (통일된 데이터 구조 사용)
//   void _showCrimeModal(dynamic data) {
//     // 데이터 구조에 따라 안정적으로 파싱
//     final region = data["region"] as Map<String, dynamic>;
//     final cnt = data["counts"] as Map<String, dynamic>;
//
//     // 읍면동 정보의 유무에 따라 타이틀 변경
//     String title = region['dong'] != null && region['dong'].isNotEmpty
//         ? "현재 위치 (${region['dong']}) 성범죄자 등록 현황"
//         : "선택 지역 (${region['sigungu']}) 성범죄자 등록 현황";
//
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 좌측 정렬
//             children: [
//               Center(
//                 child: Text(title,
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ),
//               const Divider(height: 20),
//
//               // 시도, 시군구, 읍면동 카운트 출력 (buildCountRow 사용)
//               _buildCountRow(region['sido'] as String, cnt['sidoCount']),
//               _buildCountRow(region['sigungu'] as String, cnt['sigunguCount']),
//               // 읍면동이 비어있지 않은 경우에만 출력
//               if (region['dong'] != null && region['dong'].isNotEmpty)
//                 _buildCountRow(region['dong'] as String, cnt['dongCount']),
//
//               SizedBox(height: 20),
//               Center(
//                 child: Text("자료 출처: <공공데이터포털> 여성가족부_성범죄자 공개 및 도로명 주소 정보",
//                     style: TextStyle(color: Colors.grey, fontSize: 12)),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // ★ 추가: 카운트 정보 표시 위젯
//   Widget _buildCountRow(String regionName, dynamic count) {
//     if (regionName == null || regionName.isEmpty) return SizedBox.shrink();
//
//     final countValue = count is int ? count : 0;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text('• $regionName 등록 인원수:'),
//           Text('${countValue}명', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
//         ],
//       ),
//     );
//   }
//
//
//   // ✅ Flutter → JS로 지도 중심 이동
//   void _moveToMyLocation() {
//     if (lat != null && lng != null) {
//       final js =
//       '''
//         var moveLatLon = new kakao.maps.LatLng($lat, $lng);
//         map.panTo(moveLatLon);
//         marker.setPosition(moveLatLon);
//       ''';
//       _controller.runJavaScript(js);
//     }
//   }
//
//   // ✅ 서버에서 마커 데이터 가져와 JS로 전달 (기존 로직 유지)
//   Future<void> _fetchAndShowMarkers(String category) async {
//     // ... (기존 _fetchAndShowMarkers 함수 내용 생략)
//     try {
//       String url = '';
//       if (category == "clothingBin") { // 의류수거함
//         url = "https://api.odcloud.kr/api/15141554/v1/uddi:574fcc84-bcb8-4f09-9588-9b820731bf19?page=1&perPage=368&serviceKey=lxvZMQzViYP1QmBRI9MrdDw5ZmsblpCAd5iEKcTRES4ZcynJhQxzAuydpechK3TJCn43OJmweWMoYZ10aspdgQ%3D%3D";
//       } else {
//         url = "$serverBaseUrl/api/$category"; // 임의의 서버 URL (엔드포인트 통일)
//       }
//       final response = await Dio().get(url);
//       dynamic data = response.data;
//
//       // ... (데이터 가공 로직 생략)
//
//       if (category == "clothingBin") {
//         data = data["data"];
//       }
//
//       final jsData = jsonEncode(data);
//       final jsCategory = jsonEncode(category);
//       final js = "addMarkers($jsData, $jsCategory);";
//       _controller.runJavaScript(js);
//     } catch (e) {
//       print("마커 데이터 불러오기 실패: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(child: Text('통합 지도')),
//         // ★ 수정: AppBar의 bottom 속성으로 지역 필터링 UI 배치
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(56.0),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // 시도 드롭다운
//                 DropdownButton<String>(
//                   // ★ 수정: valule -> value
//                   value: selectedSido,
//                   hint: const Text('시/도 선택'),
//                   items: sidoList.map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue){
//                     setState(() {
//                       selectedSido = newValue;
//                       selectedSigungu = null; // 시도가 바뀌면 시군구 초기화
//                     });
//                   },
//                 ),
//                 const SizedBox(width: 15),
//
//                 // 시군구 드롭다운
//                 DropdownButton<String>(
//                   value: selectedSigungu,
//                   hint: const Text('시/군/구 선택'),
//                   items: selectedSido != null && sigunguMap.containsKey(selectedSido)
//                       ? sigunguMap[selectedSido]!.map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList()
//                       : [],
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       selectedSigungu = newValue;
//                     });
//                     if (newValue != null && selectedSido != null) {
//                       // ★ 선택한 지역의 통계 데이터 로드 및 모달 표시
//                       _filterCrimeInfo(selectedSido!, newValue);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//
//           // ... (기존 FloatingActionButtons 위치는 그대로 유지)
//           Positioned(
//             right: 10,
//             bottom: 100,
//             child: Column(
//               children: [
//                 FloatingActionButton.small(
//                   heroTag: "zoomIn",
//                   onPressed: () => _controller.runJavaScript("zoomIn();"),
//                   child: const Icon(Icons.add),
//                 ),
//                 const SizedBox(height: 10),
//                 FloatingActionButton.small(
//                   heroTag: "zoomOut",
//                   onPressed: () => _controller.runJavaScript("zoomOut();"),
//                   child: const Icon(Icons.remove),
//                 ),
//               ],
//             ),
//           ),
//
//           // 왼쪽 상단 카테고리 버튼
//           // ... (생략)
//
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _initLocation,
//         child: const Icon(Icons.my_location),
//       ),
//     );
//   }
// }