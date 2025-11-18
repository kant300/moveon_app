import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'ambulance_data.dart'; // 위에서 정의한 DTO 파일 경로


class Ambulance extends StatefulWidget {
  const Ambulance({super.key});

  @override
  State<Ambulance> createState() => _AmbulanceState();
}

class _AmbulanceState extends State<Ambulance> {
  // 현재 위치 상태
  String _currentLocation = "위치 정보를 불러오는 중...";
  // 선택된 지역 (필터링 기준)
  String? _selectedRegion;
  // API로부터 로드된 전체 데이터
  List<AmbulanceDto> _allAmbulances = [];
  // 현재 화면에 표시할 필터링된 데이터
  List<AmbulanceDto> _filteredAmbulances = [];

  // 처리 기관 정보 (필터링된 데이터에서 추출)
  String _department = '';
  String _team = '';
  String _officerContact = '';
  String _agencyContact = '032-440-3253'; // 이미지에 명시된 인천 담당과 연락처 (샘플)

  // API 클라이언트
  final Dio _dio = Dio();
  final String _apiUrl = "http://YOUR_SERVER_IP:8080/api/ambulance/all"; // 실제 서버 주소로 변경하세요.


  @override
  void initState() {
    super.initState();
    _loadData();
    _determinePosition();
  }

  /// 1. 위치 정보 획득 및 현재 위치 업데이트
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _currentLocation = '위치 서비스를 켜주세요.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _currentLocation = '위치 권한이 거부되었습니다.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _currentLocation = '위치 권한을 영구적으로 허용해야 합니다.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      // 실제 위치 정보 -> 주소 변환 (Geocoder) 로직은 생략하고 샘플 텍스트 사용
      setState(() {
        // 실제로는 position.latitude와 position.longitude를 주소로 변환하여 사용해야 함.
        _currentLocation = '인천 부평구 부평동';
        // 초기 로드 시 현재 위치 기준으로 필터링을 시도할 수도 있음.
        _selectedRegion = '부평구';
      });
      _applyFilter(); // 위치 획득 후 데이터 필터링 적용
    } catch (e) {
      setState(() => _currentLocation = '위치 획득에 실패했습니다.');
    }
  }

  /// 2. 백엔드 API로부터 전체 데이터 로드
  Future<void> _loadData() async {
    try {
      final response = await _dio.get(_apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        setState(() {
          _allAmbulances = jsonList.map((json) => AmbulanceDto.fromJson(json)).toList();
        });
        _applyFilter();
      }
    } catch (e) {
      print("API 호출 오류: $e");
      // 필요시 사용자에게 오류 메시지 표시
    }
  }

  /// 3. 지역 필터링 적용 및 화면 업데이트
  void _applyFilter() {
    setState(() {
      if (_selectedRegion == null || _selectedRegion!.isEmpty) {
        _filteredAmbulances = _allAmbulances;
      } else {
        // 선택된 '지역'(시군구)을 기준으로 필터링
        _filteredAmbulances = _allAmbulances
            .where((item) => item.region == _selectedRegion)
            .toList();
      }

      // 처리 기관 정보 업데이트 (필터링된 데이터 중 첫 번째 항목 기준)
      if (_filteredAmbulances.isNotEmpty) {
        final firstItem = _filteredAmbulances.first;
        _department = firstItem.department;
        _team = firstItem.team;
        _officerContact = firstItem.officerContact;
        // 관할 기관 연락처는 시도/지역에 따라 다를 수 있으므로, 해당 로직을 추가해야 함.
        // 현재는 이미지에 나온 인천 연락처로 고정 (032-440-3253)
      } else {
        // 데이터가 없을 경우 초기화
        _department = '정보 없음';
        _team = '정보 없음';
        _officerContact = '정보 없음';
        _agencyContact = '정보 없음';
      }
    });
  }

  /// 4. 지역 선택 다이얼로그
  void _showRegionSelectionDialog() async {
    // _allAmbulances에서 유효한 '지역'(시군구) 목록을 추출
    final List<String> regions = _allAmbulances
        .map((e) => e.region)
        .where((region) => region.isNotEmpty)
        .toSet() // 중복 제거
        .toList()
      ..sort(); // 가나다순 정렬

    final selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('지역 선택'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // '현재 위치' 선택 옵션
                ListTile(
                  title: Text('현재 위치 (${_selectedRegion ?? '미설정'})'),
                  onTap: () => Navigator.pop(context, _selectedRegion),
                ),
                ...regions.map((region) => ListTile(
                  title: Text(region),
                  onTap: () => Navigator.pop(context, region),
                )),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedRegion = selected;
      });
      _applyFilter();
    }
  }

  // --- 위젯 구성 요소 ---

  // 상단 현재 위치 및 버튼
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('현재위치', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_currentLocation, style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _showRegionSelectionDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('지역선택'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 이송 버튼 액션 구현
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('이동'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('자료출처: 보건복지부 구급차_관리운영_지침(제4판)', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // 업체 현황 테이블 (업체명, 주소, 연락처)
  Widget _buildCompanyTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('업체 현황 (사설 구급차)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {
              0: FlexColumnWidth(1.5), // 업체명
              1: FlexColumnWidth(3.0), // 주소
              2: FlexColumnWidth(1.5), // 연락처
            },
            children: [
              // 헤더 행
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade200),
                children: kCompanyHeaders.map((header) =>
                    _buildTableCell(header, isHeader: true, alignment: Alignment.center))
                    .toList(),
              ),
              // 데이터 행
              ..._filteredAmbulances.map((item) => TableRow(
                children: [
                  _buildTableCell("item.companyName", alignment: Alignment.centerLeft),
                  _buildTableCell(item.address, alignment: Alignment.centerLeft),
                  _buildTableCell(item.contact, alignment: Alignment.center),
                ],
              )),
              if (_filteredAmbulances.isEmpty)
                TableRow(
                    children: [
                      // 💡 1. 메시지를 담는 셀
                      _buildTableCell("데이터가 없습니다.", alignment: Alignment.center),
                      // 💡 2. 빈 셀 (Colspan 역할을 대신)
                      _buildTableCell("", alignment: Alignment.center),
                      // 💡 3. 빈 셀 (Colspan 역할을 대신)
                      _buildTableCell("", alignment: Alignment.center),
                    ]
                )
            ],
          ),
        ],
      ),
    );
  }

  // 이송 처치료 기준 (고정 데이터)
  Widget _buildFeeTable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // 1. 이미지를 assets 폴더에 저장하고 pubspec.yaml에 경로를 등록해야 합니다.
          Image.asset(
            'assets/images/ambulance_price.PNG', // 이미지 경로를 실제 경로로 수정하세요.
            fit: BoxFit.fitWidth, // 너비에 맞게 조절
          ),
          // ----------------------------------------------------
          const SizedBox(height: 12),
          const Text(
            '이송처치료는 구급차 내에 장착된 미터기에 의해 계산되며, 영수증이 발급됩니다.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const Text(
            '아래의 경우 등과 같이 이송처치료 외의 추가비용을 요구하는 것은 불법입니다.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Text('> 왕복, 시외이유로 추가 비용을 요구하는 경우 -> 불법', style: TextStyle(color: Colors.grey)),
          const Text('> 의료장비 사용료, 처치비용, 의약품 사용 등의 추가 비용을 요구하는 경우 -> 불법', style: TextStyle(color: Colors.grey)),
          const Text('> 카드수수료, 보호자 합승비, 대기비 등의 추가 비용을 요구하는 경우 -> 불법', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // 불만 처리 기관
  Widget _buildProcessingAgency() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '탑승하신 구급차 이용과 관련한 불편사항 처리기관',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {
              0: FlexColumnWidth(2.0),
              1: FlexColumnWidth(2.0),
              2: FlexColumnWidth(2.0),
            },
            children: [
              // 헤더 행
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade200),
                children: kOfficerHeaders.map((header) =>
                    _buildTableCell(header, isHeader: true, alignment: Alignment.center))
                    .toList(),
              ),
              // 데이터 행
              TableRow(
                children: [
                  _buildTableCell(_department.isNotEmpty ? _department : '정보 없음', alignment: Alignment.center),
                  _buildTableCell(_team.isNotEmpty ? _team : '정보 없음', alignment: Alignment.center),
                  _buildTableCell(_agencyContact.isNotEmpty ? _agencyContact : '정보 없음', alignment: Alignment.center),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 공통 테이블 셀 위젯
  Widget _buildTableCell(String text, {bool isHeader = false, bool isKey = false, Alignment alignment = Alignment.center, int colspan = 1}) {
    final TextStyle style = TextStyle(
      fontWeight: isHeader || isKey ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? Colors.white : (isKey ? Colors.black : Colors.black),
      fontSize: 13,
    );

    // colspan 처리는 TableCell을 Column으로 감싸서 구현 (단순화)
    final Widget cellContent = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: alignment,
        child: Text(text, style: style, textAlign: TextAlign.center),
      ),
    );

    if (colspan > 1) {
      return TableCell(child: cellContent); // 실제 ColumnSpan 로직이 아니므로 주의
    }
    return TableCell(child: cellContent);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사설 구급차 이용 안내', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
            _buildCompanyTable(),
            _buildFeeTable(),
            _buildProcessingAgency(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // 네비게이션 바 (요청에 따라 생략)
      // bottomNavigationBar: const BottomNavBar(),
    );
  }
}