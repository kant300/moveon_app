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
  // ★ 추가: 지역 필터링을 위한 변수
  String? selectedSido;
  String? selectedSigungu;
  // ★ 추가: 지역 필터링용 데이터 (실제 데이터에 맞게 조정 필요)
  // final List<String> sidoList = ['서울', '인천', '경기'];
  final List<String> sidoList = [ '인천' ];
  final Map<String, List<String>> sigunguMap = {
    '인천': ['강화군','계양구','남동구','동구', '미추홀구','부평구', '서구','연수구','옹진군','중구'],
    // '서울': ['강남구', '서초구', '마포구'],
    // '경기': ['수원시', '성남시', '용인시'],
  };

  final String kakaoJsKey = '9eb4f86b6155c2fa2f5dac204d2cdb35';
  final String serverBaseUrl = 'http://192.168.40.61:8080';

  @override
  void initState() {
    super.initState();

    /// ============================
    /// 1) Kakao Map HTML
    /// ============================
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
    // ✅ 수정 코드: 지연 시간(500ms)을 주어 라이브러리 로드를 기다림
    setTimeout(function() {
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
      // 내 위치 마커 클릭 → Flutter 전달
      kakao.maps.event.addListener(marker, 'click', function() {
        if (window.flutterChannel) {
          window.flutterChannel.postMessage("myLocationClick");
        }
      }, 500); // 0.5초 대기
      
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
              // } else if (category == "sexcrime") { // 성범죄자
              //   window.infowindow.setContent('<div style="width:400px;text-align:center;padding:10px;">' +
              //   '</div>');
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
      ..addJavaScriptChannel(
        'flutterChannel',
        onMessageReceived: (msg) {
          if (msg.message == "myLocationClick") {
            // ★ 수정: 내 위치 마커 클릭 시, 현재 lat/lng로 통계 정보 로드
            _loadCrimeInfo(lat, lng);   // ← 내위치 마커 클릭 시 서버 호출
          }
        },
      )
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

      // ★ 초기 시도/시군구 설정
      // (실제로는 지오코딩 결과를 이용해야 하지만, 예시를 위해 기본값 설정)
      selectedSido = '인천';
      selectedSigungu = '부평구';

      // 지도 이동
      _moveToMyLocation();

      // ✅ 서버에서 마커 데이터 가져오기 (현재 의류수거함을 기본 데이터로 설정)
      await _fetchAndShowMarkers("clothingBin");
    } else {
      await openAppSettings();
    }
  }

  // 서버 REST 호출해서 성범죄자 통계 가져오기
  // ★ 수정: 현재 위치 기반 성범죄자 통계 가져오기 (마커 클릭 시)
  Future<void> _loadCrimeInfo(double? clickLat, double? clickLng) async {
    if (clickLat == null || clickLng == null) return;

    try {
      // sexcrime/near 엔드포인트는 지오코딩 + 지역 카운트 기능을 모두 수행한다고 가정
      final res = await Dio().get(
        "http://192.168.40.61:8080/api/sexcrime/near",
        queryParameters: {"lat": clickLat, "lng": clickLng},
      );

      _showCrimeModal(res.data);

    } catch (e) {
      print("성범죄자 통계 불러오기 오류: $e");
    }
  }

  // ★ 추가: 지역 필터링 기반 성범죄자 통계 가져오기
  Future<void> _filterCrimeInfo(String sido, String sigungu) async {
    try {
      // 읍면동 정보가 없는 경우, 서버에서 시군구 단위 카운트를 반환한다고 가정
      final res = await Dio().get(
        "$serverBaseUrl/safety/sexcrime/count",
        queryParameters: {"sido": sido, "sigungu": sigungu, "dong": ""},
      );

      // 임시로 지역 정보를 함께 구성 (서버에서 sido/sigungu를 다시 보내주지 않는 경우)
      final data = {
        "region": {"sido": sido, "sigungu": sigungu, "dong": "없음"},
        "counts": res.data
      };

      _showCrimeModal(data);
    } catch (e) {
      print("지역 필터링 통계 불러오기 오류: $e");
    }
  }

  // ★ 모달로 표시 (통일된 데이터 구조 사용)
  void _showCrimeModal(dynamic data) {
    // 서버에서 받은 데이터 구조: {"region": {"sido": "...", "sigungu": "...", "dong": "..."}, "counts": {...}}
    final region = data["region"] as Map<String, dynamic>;
    final cnt = data["counts"] as Map<String, dynamic>;

    // 모달 타이틀 설정 (지역 기반 필터링인지, 현재 위치 기반인지 구분)
    String title = (region['dong'] != null && region['dong'].isNotEmpty && region['dong'] != '없음')
        ? "현재 위치 (${region['dong']}) 성범죄자 등록 현황"
        : "선택 지역 (${region['sigungu']}) 성범죄자 등록 현황"; // 읍면동이 없거나 '없음'이면 시군구 기준으로 표시

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [// ✅ 수정: 미리 정의한 title 변수를 사용하여 제목 출력
              Center(
                child: Text(title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 20),

              /// 시/도
              // ✅ 수정: _buildCountRow 위젯을 사용하여 통일된 방식으로 출력
              _buildCountRow(region['sido'] as String, cnt['sidoCount']),
              /// 시군구
              _buildCountRow(region['sigungu'] as String, cnt['sigunguCount']),

              /// 읍면동 (dong이 '없음'이거나 비어있지 않은 경우에만 표시)
              if (region['dong'] != null && region['dong'].isNotEmpty && region['dong'] != '없음')
                _buildCountRow(region['dong'] as String, cnt['dongCount']),

              SizedBox(height: 20),
              Text("자료 출처: <공공데이터포털> 여성가족부_성범죄자 공개 및 도로명 주소 정보",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  // ★ 추가: 카운트 정보 표시 위젯
  Widget _buildCountRow(String regionName, dynamic count) {
    if (regionName == null || regionName.isEmpty) return SizedBox.shrink();

    // count가 int가 아닌 경우 0으로 처리 (혹시 모를 에러 방지)
    final countValue = count is int ? count : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('• $regionName 등록 인원수:'),
          Text('${countValue}명', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
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
        url = "http://192.168.40.61:8080/living/gov";
        // key: 유형, 시설명, 주소, 전화번호, 경도, 위도
      } else if (category == "night") { // 심야약국/병원
        url = "http://192.168.40.61:8080/living/medical";
        // key: 유형, 시설명, 주소, 전화번호, 경도, 위도
      } else if (category == "sexCrime") { // 성범죄자
        url = "http://192.168.40.61:8080/safety/api/sexcrime/near";
        // key: 유형, 시설명, 주소, 전화번호, 경도, 위도
      } else if (category == "shelter") { // 대피소
        url = "http://192.168.40.61:8080/safety/shelter";
        // key: 시설명, 위도, 경도
      } else if (category == "restroom") { // 공중화장실
        url = "http://192.168.40.61:8080/safety/toilet";
        // key: 화장실명, 소재지도로명주소, 관리기관명, 전화번호, 개방시간상세, 위도, 경도
      } else if (category == "subwayLift") { // 지하철/승강기
        url = "http://192.168.40.61:8080/transport/lift";
        // key: 역사, 장비, 호기, 위도, 경도, 상태
      } else if (category == "subwaySchedule") { // 지하철/배차
        url = "http://192.168.40.61:8080/transport/location";
        // key: 역사명, 위도, 경도
      } else if (category == "wheelchairCharger") { // 전동휠체어
        url = "http://192.168.40.61:8080/api/chargers/all";
        // key: 시설명, 소재지도로명주소, 위도, 경도, 평일운영시작시각, 평일운영종료시각, 관리기관명
      } else if (category == "localParking") { // 공영주차장
        url = "http://192.168.40.61:8080/transport/parking";
        // key: name, long, lat (시설명, 경도, 위도)
      } else if (category == "gas") {
        url = "http://192.168.40.61:8080/transport/gas";
        // key: 업소명, 소재지, 위도, 경도, 전화번호
      }
      final response = await Dio().get(url);
      data = response.data;

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

          final responseTime = await Dio().get("http://192.168.40.61:8080/transport/schedule", queryParameters: {"station_name": stationName});
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
      appBar: AppBar(title: const Center(child: Text('통합 지도')),
      // ★ 추가: 상단 지역 필터링 UI
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 시도 드롭다운
                  DropdownButton<String>(
                      value: selectedSido,
                      hint: Text('시/도 선택'),
                      items: sidoList.map((String value) {
                        return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                        );;
                      }).toList(),
                      onChanged: (String? newValue){
                        setState(() {
                          selectedSido = newValue;;
                          selectedSigungu = null; // 시도가 바뀌면 시군구 초기화
                        });
                      },
                  ),
                  const SizedBox(width: 15),

                  // 시군구 드롭다운
                  DropdownButton<String>(
                    value: selectedSigungu,
                    hint: Text('시/군/구 선택'),
                    items: selectedSido != null && sigunguMap.containsKey(selectedSido)
                        ? sigunguMap[selectedSido]!.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                        : [],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSigungu = newValue;
                      });
                      if (newValue != null && selectedSido != null) {
                        // ★ 선택한 지역의 통계 데이터 로드 및 모달 표시
                        _filterCrimeInfo(selectedSido!, newValue);
                      }
                    },
                  ),
                ],
              ),
          ),
        ),
      ),

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