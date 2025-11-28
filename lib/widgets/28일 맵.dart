// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'ExpandableCategoryList.dart';
// import 'package:moveon_app/safety/sexcrime/SexCrimeFilterModal.dart';
//
// // ✅ 1. 파일 최상단에 BASE_URL 상수 정의
// const String BASE_URL = "http://192.168.40.61:8080";
// // 🚨 서버 주소가 변경되면 이 상수의 값만 수정하면 됩니다.
//
// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   String? _currentCategoryKey; // 현재 지도에 표시할 카테고리
//
//   // ⭐️ 마커를 로드하는 함수 (실제 구현 필요)
//   void _loadMarkersForCategory(String key) {
//     print("지도: $key 카테고리 마커 로딩 시작");
//     // 여기에 Dio를 사용하여 서버에서 해당 카테고리 마커 데이터를 가져오는 로직 구현
//   }
//
//   // ⭐️ ExpandableCategoryList의 콜백 함수
//   void _handleCategorySelected(String key) {
//     setState(() {
//       _currentCategoryKey = key;
//       _loadMarkersForCategory(key);
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//     // ⭐️ (1) menu.dart에서 전달받은 인수를 확인합니다.
//     final args = ModalRoute.of(context)?.settings.arguments;
//
//     // ⭐️ (2) 초기 진입 시에만 처리합니다.
//     if (_currentCategoryKey == null && args is String) {
//       final initialKey = args;
//       print("지도 초기화: 메뉴에서 '$initialKey' 키를 받았습니다.");
//
//       // 상태를 설정하고 마커 로딩을 시작합니다.
//       _handleCategorySelected(initialKey);
//
//       // ⚠️ 중요: ModalRoute.of(context)?.settings.arguments = null;
//       // 인수를 한 번 사용한 후 null로 설정하여 뒤로가기 시 인수가 재사용되는 것을 방지할 수 있습니다.
//       // 하지만, 뒤로가기 시에도 인수가 필요 없다면 이 부분이 가장 안전합니다.
//     }
//
//     // 만약 ExpandableCategoryList가 MapScreen에 포함되어 있다면,
//     // _currentCategoryKey를 그 위젯에 전달하여 초기 상태를 표시하게 할 수도 있습니다.
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(_currentCategoryKey ?? '전체 지도')),
//       body: Stack(
//         children: [
//           // 맵 위젯 구현 부분
//           Center(
//             child: Text('지도 표시: $_currentCategoryKey 카테고리'),
//           ),
//
//           // ⭐️ ExpandableCategoryList 위젯 (map.dart 내에 위치)
//           Positioned(
//             top: 10,
//             left: 10,
//             child: VerticalHorizontalCategoryList(
//               onCategorySelected: _handleCategorySelected, // 콜백 연결
//               // 참고: ExpandableCategoryList 위젯의 초기 상태를
//               //       _currentCategoryKey로 설정하는 로직이 필요할 수 있습니다.
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
//   // ✅ 검색어 입력 컨트롤러 추가
//   final TextEditingController _searchController = TextEditingController();
//
//   final String kakaoJsKey = '9eb4f86b6155c2fa2f5dac204d2cdb35';
//
//   dynamic args = null;
//
//   // ✅ 1. 성범죄자 필터링 상태 변수 추가
//   String _sexCrimeFilterSido = '';
//   String _sexCrimeFilterSigungu = '';
//   String _sexCrimeFilterDong = '';
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // ⭐️ (1) menu.dart에서 전달받은 인수를 확인합니다.
//     args = ModalRoute.of(context)?.settings.arguments;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     /// ============================
//     /// 1) Kakao Map HTML
//     /// ============================
//     final html =
//     '''
// <!DOCTYPE html>
// <html>
//   <head>
//     <meta charset="utf-8" />
//     <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
//     <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=$kakaoJsKey&libraries=services,clusterer"></script>
//     <style>
//       /* 인포윈도우 스타일 (선택사항) */
//       .infowindow-content {
//         display: flex;
//         flex-direction: column;
//         gap: 5px;
//         padding: 10px;
//         text-align: center;
//       }
//     </style>
//   </head>
//   <body style="margin:0;">
//     <div id="map" style="width:100%;height:100vh;"></div>
//     <script>
//       // ✅ BASE_URL 정의는 반드시 <script> 태그 내부의 맨 위에 위치해야 합니다.
//       const BASE_URL = "http://192.168.40.61:8080";
//       var mapContainer = document.getElementById('map');
//       var mapOption = {
//         center: new kakao.maps.LatLng(37.5665, 126.9780),
//         level: 3
//       };
//       var map = new kakao.maps.Map(mapContainer, mapOption);
//
//       // ============================================
//       // 📌 1. 마커 이미지 정의 (사용하실 이미지 URL로 변경하세요)
//       // ============================================
//
//       // 마커 이미지 기본 설정
//       var defaultImageSize = new kakao.maps.Size(40, 40); // 기본 마커 크기
//       var defaultImageOption = {offset: new kakao.maps.Point(20, 40)}; // 이미지 중심점
//
//       // 카테고리별 마커 이미지 정의 (예시 URL)
//       var markerImages = {
//         "clothingBin": new kakao.maps.MarkerImage(BASE_URL + '/images/apparel.png', defaultImageSize, defaultImageOption),
//         "government": new kakao.maps.MarkerImage(BASE_URL + '/images/government.png', defaultImageSize, defaultImageOption),
//         "night": new kakao.maps.MarkerImage(BASE_URL + '/images/hospital.png', defaultImageSize, defaultImageOption),
//         //"sexcrime": new kakao.maps.MarkerImage(BASE_URL + '/images/crime_icon.png', defaultImageSize, defaultImageOption),
//         "water": new kakao.maps.MarkerImage(BASE_URL + '/images/water.png', defaultImageSize, defaultImageOption),
//         "shelter": new kakao.maps.MarkerImage(BASE_URL + '/images/shelter.png', defaultImageSize, defaultImageOption),
//         "restroom": new kakao.maps.MarkerImage(BASE_URL + '/images/wc.png', defaultImageSize, defaultImageOption),
//         "subwayLift": new kakao.maps.MarkerImage(BASE_URL + '/images/elevator.png', defaultImageSize, defaultImageOption),
//         "subwaySchedule": new kakao.maps.MarkerImage(BASE_URL + '/images/subway.png', defaultImageSize, defaultImageOption),
//         "wheelchairCharger": new kakao.maps.MarkerImage(BASE_URL + '/images/charger.png', defaultImageSize, defaultImageOption),
//         "localParking": new kakao.maps.MarkerImage(BASE_URL + '/images/parking.png', defaultImageSize, defaultImageOption),
//         //"gas": new kakao.maps.MarkerImage(BASE_URL + '/images/gas_icon.png', defaultImageSize, defaultImageOption),
//         "cctv": new kakao.maps.MarkerImage(BASE_URL + '/images/cctv.png', defaultImageSize, defaultImageOption),
//         // 기본 마커 (정의하지 않은 카테고리 대비)
//         "default": null
//       };
//
//       // 현재 본인 위치
//       var marker = new kakao.maps.Marker({
//         position: new kakao.maps.LatLng(37.5665, 126.9780)
//       });
//       marker.setMap(map);
//
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
//         // ✅ 기존 마커 제거
//         clusterer.clear();
//         var markers = [];
//
//         // ✅ 기존 인포윈도우 닫기
//         if (window.infowindow && window.infowindow.close) {
//           window.infowindow.close();
//         }
//         window.infowindow = new kakao.maps.InfoWindow();
//
//         // ✅ 현재 카테고리에 맞는 마커 이미지 선택
//         var selectedImage = markerImages[category] || markerImages["default"];
//
//         for (var i = 0; i < markerList.length; i++) {
//           (function(m) { // 클로저로 i값 고정
//             if (category == "localParking") { // 공영주차장은 데이터 형식이 다름
//               var markerPosition = new kakao.maps.LatLng(m["lat"], m["long"]);
//             } else {
//               var markerPosition = new kakao.maps.LatLng(m["위도"], m["경도"]);
//             }
//
//             // 마커 생성시 선택된 이미지 적용
//             var marker = new kakao.maps.Marker({
//               position: markerPosition,
//               image: selectedImage // ✅ 카테고리별 마커 이미지 적용!
//             });
//             markers.push(marker);
//
//             // ✅ 마커 클릭 시 인포윈도우 열기
//             kakao.maps.event.addListener(marker, 'click', function() {
//               var content = '';
//               // category 에 따라 infoWindow 데이터 삽입
//               if (category == "clothingBin") { // 의류수거함
//                 window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                   m["도로명 주소"] +
//                 '</div>');
//               } else if (category == "government") { // 관공서
//                 window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                   '<div>' + m["시설명"] + '</div>' +
//                   '<div>' + m["주소"] + '</div>' +
//                   '<div>' + m["전화번호"] + '</div>' +
//                 '</div>');
//               } else if (category == "night") { // 심야약국/병원
//                 window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                   '<div>' + m["시설명"] + '</div>' +
//                   '<div>' + m["주소"] + '</div>' +
//                   '<div>' + m["전화번호"] + '</div>' +
//                 '</div>');
//               } else if (category == "sexcrime") { // 성범죄자
//                 return;
//               } else if (category == "water") { // 비상급수시설
//               window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                 '<div> 시설관리번호: ' + m["id"] + '</div>' +
//                 '<div> 시도: ' + m["city"] + '</div>' +
//                 '<div> 시군구: ' + m["district"] + '</div>' +
//                 '<div> 도로명: ' + m["roadName"] + '</div>' +
//                 '<div> 읍면동: ' + m["emd"] + '</div>' +
//               '</div>');
//               } else if (category == "shelter") { // 대피소
//                 window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                   m["시설명"] +
//                 '</div>');
//               } else if (category == "restroom") { // 공중화장실
//                 window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                   '<div>' + m["화장실명"] + '</div>' +
//                   '<div>' + m["소재지도로명주소"] + '</div>' +
//                   '<div>관리기관: ' + m["관리기관명"] + ' ' + m["전화번호"] + '</div>' +
//                   '<div>개방시간: ' + m["개방시간상세"] + '</div>' +
//                 '</div>');
//               } else if (category == "subwayLift") { // 지하철/승강기
//                 window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                   '<div>' + m["역사"] + '역</div>' +
//                   '<div>' + m["호기"] + '호 ' + m["장비"] + '</div>' +
//                   '<div>' + m["상태"] + '</div>' +
//                 '</div>');
//               } else if (category == "subwaySchedule") { // 지하철/배차
//                 window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                   '<div><strong>' + m["역사명"] + '역 배차 정보</strong></div>' +
//                   (m["prevStation"] == "none"
//                     ? ''
//                     : (m["time_first_1"] <= 0 || m["time_second_1"] <= 0
//                         ? '<div>' + m["prevStation"] + '역 방면: 배차 정보가 없습니다.</div>'
//                         : '<div>' + m["prevStation"] + '역 방면: ' + m["time_first_1"] + '분 후 도착, ' + m["time_second_1"] + '분 후 도착</div>'
//                       )
//                   ) +
//                   (m["nextStation"] == "none"
//                     ? ''
//                     : (m["time_first_2"] <= 0 || m["time_second_2"] <= 0
//                         ? '<div>' + m["nextStation"] + '역 방면: 배차 정보가 없습니다.</div>'
//                         : '<div>' + m["nextStation"] + '역 방면: ' + m["time_first_2"] + '분 후 도착, ' + m["time_second_2"] + '분 후 도착</div>'
//                       )
//                   ) +
//                 '</div>');
//               } else if (category == "wheelchairCharger") { // 전동휠체어
//                 window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                   '<div>' + m["시설명"] + '</div>' +
//                   '<div>' + m["소재지도로명주소"] + '</div>' +
//                   '<div>평일: ' + m["평일운영시작시각"] + "~" + m["평일운영종료시각"] + '</div>' +
//                   '<div>' + m["관리기관명"] + '</div>' +
//                 '</div>');
//               } else if (category == "localParking") { // 공영주차장
//                 window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                   m["name"] +
//                 '</div>');
//               } else if (category == "gas") {
//                 window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
//                   '<div>' + m["업소명"] + '</div>' +
//                   '<div>' + m["소재지"] + '</div>' +
//                   '<div>' + m["전화번호"] + '</div>' +
//                 '</div>');
//               }  else if (category == "cctv") {
//                 window.infowindow.setContent('<div style="width:200px;text-align:left;padding:10px;">' +
//                   '<div> 카메라대수: ' + m["카메라대수"] + '</div>' +
//                   '<div> 촬영장면: ' + m["촬영장면정보"] + '</div>' +
//                   '<div> 설치목적: ' + m["설치목적구분"] + '</div>' +
//                 '</div>');
//               }
//
//
//               window.infowindow.open(map, marker);
//             });
//           })(markerList[i]);
//         }
//         // 클러스터러에 마커들을 추가합니다
//         clusterer.addMarkers(markers);
//       }
//
//       // ============================================
//       // ✅ 주소 검색 관련 JavaScript 추가 (핵심)
//       // ============================================
//       var geocoder = new kakao.maps.services.Geocoder();
//       var serchMarker = null; // 검색 시 생성되는 마커
//
//       // Flutter에서 검색어를 받아 주소 검색을 실행하는 함수
//       window.searchAddress = function(query) {
//         if (searchMarker) {
//           searchMarker.setMap(null); // 기존 검색 마커 제거
//         }
//
//         geocoder.addressSearch(query, function(result, status) {
//           if (status === kakao.maps.services.Status.OK) {
//             var coords = new kakao.maps.LatLng(result[0].y, result[0].x);
//
//             // 지도 중심 이동 및 레벨 설정
//             map.panTo(coords);
//             map.setLevel(3); // 적절한 줌 레벨로 설정
//
//             // 검색 마커 생성 및 표시
//             searchMarker = new kakao.maps.Marker({
//               map: map,
//               position: coords
//             });
//
//             // 검색 결과를 Dart로 전달 (위도, 경도)
//             if (window.flutterChannel) {
//               window.flutterChannel.postMessage("searchDone," + result[0].y + "," + result[0].x);
//             }
//           } else {
//             // 검색 실패 시 Dart로 알림
//             if (window.flutterChannel) {
//               window.flutterChannel.postMessage("searchFailed");
//             }
//           }
//         });
//       };
//
//       // ✅ 지도 확대 / 축소 함수 추가
//       function zoomIn() {
//         map.setLevel(map.getLevel() - 1); // 레벨 1 감소 = 확대
//       }
//       function zoomOut() {
//         map.setLevel(map.getLevel() + 1); // 레벨 1 증가 = 축소
//       }
//
//     </script>
//   </body>
// </html>
// ''';
//
//
//
//     _controller = WebViewController()
//       ..addJavaScriptChannel(
//         'flutterChannel',
//         onMessageReceived: (msg) {
//           if (msg.message == "myLocationClick") {
//             _loadCrimeInfo();   // ← 내위치 마커 클릭 시 서버 호출
//           }else if (msg.message.startsWith("searchDone,")) {
//             // ✅ 검색 성공 결과 처리: "searchDone,위도,경도"
//             final parts = msg.message.split(',');
//             final lat = double.tryParse(parts[1]);
//             final lng = double.tryParse(parts[2]);
//             if (lat != null && lng != null) {
//               // 검색된 좌표로 현재 Dart 변수를 업데이트하고 (필요하다면) 통계 로드
//               _updateLocationAfterSearch(lat, lng);
//             }
//           }else if (msg.message == "searchFailed") {
//             // ✅ 검색 실패 처리
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('검색 결과를 찾을 수 없습니다.')),
//             );
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
//     // 초기 위치 + 마커 로드
//     _initLocation();
//   }
//
//   // ✅ Dart에서 JS의 searchAddress 함수 호출
//   void _performSearch(String query) {
//     if (query.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('검색어를 입력해 주세요.')),
//       );
//       return;
//     }
//     // JS 함수를 호출하여 주소 검색 실행
//     _controller.runJavaScript("searchAddress('${query.trim()}');");
//   }
//
//
//
//   // ✅ 검색 후 Dart 위치 변수 업데이트
//   void _updateLocationAfterSearch(double latitude, double longitude) {
//     // 검색된 좌표로 현재 위치 변수를 업데이트
//     setState(() {
//       lat = latitude;
//       lng = longitude;
//     });
//   }
//
//
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
//       // 지도 이동
//       _moveToMyLocation();
//
//       // ✅ 서버에서 마커 데이터 가져오기 (현재 의류수거함을 기본 데이터로 설정)
//       await _fetchAndShowMarkers( args ?? "clothingBin" );
//     } else {
//       await openAppSettings();
//     }
//   }
//
//
//
//   // ============================================
//   // ⭐️ 성범죄자 통계 및 모달 관련 함수 수정 ⭐️
//   // ============================================
//
//   // 서버 REST 호출해서 성범죄자 통계 가져오기
//   Future<void> _loadCrimeInfo() async {
//     if (lat == null || lng == null) return;
//
//     try {
//       // 필터링 변수를 사용하여 URL에 쿼리 파라미터를 추가합니다.
//       String filterQuery = '';
//       if (_sexCrimeFilterSido.isNotEmpty) filterQuery += '&sido=$_sexCrimeFilterSido';
//       if (_sexCrimeFilterSigungu.isNotEmpty) filterQuery += '&sigungu=$_sexCrimeFilterSigungu';
//       if (_sexCrimeFilterDong.isNotEmpty) filterQuery += '&dong=$_sexCrimeFilterDong';
//
//       final res = await Dio().get(
//         "$BASE_URL/api/safety/sexcrime/near",
//         queryParameters: {
//           "lat": lat,
//           "lng": lng,
//           // 필터 파라미터는 이미 URL에 추가되었으므로 여기서는 lat/lng만 전달하거나
//           // 아니면 아래와 같이 queryParameters 맵에 모두 넣어 Dio가 처리하게 합니다.
//           "sido": _sexCrimeFilterSido,
//           "sigungu": _sexCrimeFilterSigungu,
//           "dong": _sexCrimeFilterDong,
//         },
//       );
//
//       // 모달 표시 함수를 새 필터 모달로 변경
//       _showCrimeFilterModal(res.data);
//
//     } catch (e) {
//       print("성범죄자 통계 불러오기 오류: $e");
//       // 필요 시 사용자에게 알림
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //     const SnackBar(content: Text('성범죄자 정보를 불러오는 데 실패했습니다.')),
//       // );
//     }
//   }
//   // ✅ 3. 필터링 기능을 가진 새 모달로 변경
//   void _showCrimeFilterModal(dynamic data) {
//     final region = data["region"];
//     final cnt = data["counts"];
//     final initialData = {
//       "${region['sido']} (현재 위치 기준)": cnt['sidoCount'] as int? ?? 0,
//       "${region['sigungu']}": cnt['sigunguCount'] as int? ?? 0,
//       "${region['dong']}": cnt['dongCount'] as int? ?? 0,
//     };
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // 내부 콘텐츠에 따라 높이가 유연하게 설정되도록
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return SexCrimeFilterModal(
//           initialData: initialData,
//           onFilterApplied: _applyCrimeFilterAndLoadMarkers, // 👈 콜백 함수 연결
//         );
//       },
//     );
//   }
//
//   // ✅ 4. 모달에서 필터 적용 시 호출될 함수 (가장 중요)
//   Future<void> _applyCrimeFilterAndLoadMarkers(String sido, String sigungu, String dong) async {
//     // 4-1. 선택된 필터 값을 상태 변수에 저장
//     setState(() {
//       _sexCrimeFilterSido = sido;
//       _sexCrimeFilterSigungu = sigungu;
//       _sexCrimeFilterDong = dong;
//     });
//
//     // 4-2. 성범죄자 마커 로딩 함수 재호출
//     await _fetchAndShowMarkers("sexCrime");
//   }
//
//
//
//
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
//   // ============================================
//   // ⭐️ _fetchAndShowMarkers 함수 수정 ⭐️
//   // ============================================
//
//   // ✅ 서버에서 마커 데이터 가져와 JS로 전달 (sexCrime 카테고리 로직 변경)
//   Future<void> _fetchAndShowMarkers(String category) async {
//     try {
//       String url = '';
//       dynamic data = [];
//       if (category == "clothingBin") { // 의류수거함
//         url = "https://api.odcloud.kr/api/15141554/v1/uddi:574fcc84-bcb8-4f09-9588-9b820731bf19?page=1&perPage=368&serviceKey=lxvZMQzViYP1QmBRI9MrdDw5ZmsblpCAd5iEKcTRES4ZcynJhQxzAuydpechK3TJCn43OJmweWMoYZ10aspdgQ%3D%3D";
//         // key: 경도, 관리번호, 도로명 주소, 연번, 위도
//       } else if (category == "government") { // 관공서
//         url = "$BASE_URL/living/gov";
//         // key: 유형, 시설명, 주소, 전화번호, 경도, 위도
//       } else if (category == "night") { // 심야약국/병원
//         url = "$BASE_URL/living/medical";
//         // key: 유형, 시설명, 주소, 전화번호, 경도, 위도
//       } else if (category == "sexCrime") { // 성범죄자
//         // ⭐️ lat/lng 외에 저장된 필터 변수도 쿼리 파라미터로 사용
//         String filterQuery = '';
//         if (_sexCrimeFilterSido.isNotEmpty) filterQuery += '&sido=$_sexCrimeFilterSido';
//         if (_sexCrimeFilterSigungu.isNotEmpty) filterQuery += '&sigungu=$_sexCrimeFilterSigungu';
//         if (_sexCrimeFilterDong.isNotEmpty) filterQuery += '&dong=$_sexCrimeFilterDong';
//
//         // 필터 변수가 비어 있으면 현재 위치 기준으로 호출됨
//         url = "$BASE_URL/api/sexcrime/near?lat=${lat}&lng=${lng}$filterQuery";
//         // key: 유형, 시설명, 주소, 전화번호, 경도, 위도
//       } else if (category == "water") { // 비상급수시설
//         url = "$BASE_URL/api/water";
//         // key: 시설명, 위도, 경도
//       } else if (category == "shelter") { // 대피소
//         url = "$BASE_URL/safety/shelter";
//         // key: 시설명, 위도, 경도
//       } else if (category == "restroom") { // 공중화장실
//         url = "$BASE_URL/safety/toilet";
//         // key: 화장실명, 소재지도로명주소, 관리기관명, 전화번호, 개방시간상세, 위도, 경도
//       } else if (category == "subwayLift") { // 지하철/승강기
//         url = "$BASE_URL/transport/lift";
//         // key: 역사, 장비, 호기, 위도, 경도, 상태
//       } else if (category == "subwaySchedule") { // 지하철/배차
//         url = "$BASE_URL/transport/location";
//         // key: 역사명, 위도, 경도
//       } else if (category == "wheelchairCharger") { // 전동휠체어
//         url = "$BASE_URL/api/chargers/all";
//         // key: 시설명, 소재지도로명주소, 위도, 경도, 평일운영시작시각, 평일운영종료시각, 관리기관명
//       } else if (category == "localParking") { // 공영주차장
//         url = "$BASE_URL/transport/parking";
//         // key: name, long, lat (시설명, 경도, 위도)
//       } else if (category == "gas") {
//         url = "$BASE_URL/transport/gas";
//         // key: 업소명, 소재지, 위도, 경도, 전화번호
//       }
//       else if (category == "cctv") {
//         url = "$BASE_URL/api/cctv/all?lat=${lat}&lng=${lng}";
//         // key: 업소명, 소재지, 위도, 경도, 전화번호
//       }
//
//       final response = await Dio().get(url);
//       data = response.data;
//
//       print( data );
//
//       // 지하철/배차는 배차 시각 정보를 추가해야 함
//       if (category == "subwaySchedule") {
//         // 현재 시간 today 를 int 로 변환
//         // UTC -> KST 시간으로 변경 (9시간 추가)
//         final today = DateTime.now().add(Duration(hours: 9));
//         // print(today);
//         final now = today.hour * 60 + today.minute;
//         // print(now);
//
//         // 시간 → "n분 후 도착" 또는 "배차 정보 없음"
//         int formatArrival(String? time) {
//           if (time == null || time.isEmpty) return 0;
//
//           // 매개변수 time 을 int 로 변환
//           final parts = time.split(":").map(int.parse).toList();
//           final currentTime = parts[0] * 60 + parts[1];
//           // print(currentTime);
//
//           // time 과 today 를 비교해서 시간 차이 diff ('n분 후' 형식) 알아내기
//           final diff = currentTime - now;
//           return diff < 0 ? 0 : diff;
//         }
//
//         for (int i=0; i<data.length; i++) {
//           dynamic stationName = data[i]["역사명"];
//           // 이전 역, 다음 역 이름 삽입
//           data[i]["prevStation"] = i > 0 ? data[i-1]["역사명"] : "none";
//           data[i]["nextStation"] = i < data.length-1 ? data[i+1]["역사명"] : "none";
//
//           final responseTime = await Dio().get("http://192.168.40.61:8080/transport/schedule", queryParameters: {"station_name": stationName});
//           // [LocalTime, LocalTime]
//
//           if (responseTime.statusCode == 200 && responseTime.data is List && responseTime.data.length >= 2) {
//             final prevTimes = responseTime.data[0];
//             final nextTimes = responseTime.data[1];
//
//             // n분 후 형식으로 시간 파싱하여 삽입
//             data[i]["time_first_1"] = formatArrival(prevTimes[0]);
//             data[i]["time_second_1"] = formatArrival(prevTimes[1]);
//             data[i]["time_first_2"] = formatArrival(nextTimes[0]);
//             data[i]["time_second_2"] = formatArrival(nextTimes[1]);
//           } else {
//             data[i]["time_first_1"] = 0;
//             data[i]["time_second_1"] = 0;
//             data[i]["time_first_2"] = 0;
//             data[i]["time_second_2"] = 0;
//           }
//         }
//       }
//
//       // 의류수거함은 데이터 형식이 다름
//       if (category == "clothingBin") {
//         data = data["data"];
//       }
//
//       // ✅ 6. sexCrime 처리 로직 변경: 마커 로딩 후 통계 모달을 띄우지 않습니다.
//       // 마커 로딩은 _fetchAndShowMarkers가 담당하고,
//       // 통계 모달은 '내 위치 마커 클릭' 시에만 _loadCrimeInfo()를 통해 띄웁니다.
//       // 마커 로딩만 실행하고, 모달은 _applyCrimeFilterAndLoadMarkers 함수에서 다시 띄우지 않습니다.
//       // 마커 로딩 후 모달을 바로 띄우고 싶다면 이 부분을 다시 활성화하고 필터 변수를 전달해야 합니다.
//       /*
//       if( category == "sexCrime" ){
//         // 마커 로딩 후, 업데이트된 통계 정보를 다시 불러와 모달에 표시할 수 있습니다.
//         await _loadCrimeInfo();
//       }
//       */
//
//       // 최종 데이터 확인
//       // print( data );
//
//       // sexCrime의 경우, data는 통계 정보가 아니라 마커 데이터 리스트여야 합니다.
//       // 서버 API가 성범죄자 리스트를 반환한다고 가정하고 코드를 이어갑니다.
//
//       if( category == "sexCrime" ){
//         _showCrimeFilterModal(data);
//         return;
//       }
//
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
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//
//           // ✅ 1. 주소 검색창 UI 추가
//           Positioned(
//             top: 10,
//             left: 10,
//             right: 10,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8.0),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _searchController,
//                       decoration: const InputDecoration(
//                         hintText: '장소, 주소 검색',
//                         border: InputBorder.none,
//                       ),
//                       // 엔터키 입력 시 검색 실행
//                       onSubmitted: (value) => _performSearch(value),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.search),
//                     color: Theme.of(context).primaryColor,
//                     onPressed: () => _performSearch(_searchController.text),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//
//
//           // 오른쪽 하단 확대/축소 버튼
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
//           Positioned(
//             left: 10,
//             top: 70,
//             child: VerticalHorizontalCategoryList( // 평 확장 위젯으로 변경
//               onCategorySelected: (categoryKey) async {
//                 if (categoryKey == "sexCrime") {
//                   await _loadCrimeInfo();
//                 } else {
//                   // 하위 카테고리 선택 시 마커 로드 함수 호출
//                   await _fetchAndShowMarkers(categoryKey);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _initLocation,
//         child: const Icon(Icons.my_location),
//       ),
//     );
//   }
// }
//
//
//
