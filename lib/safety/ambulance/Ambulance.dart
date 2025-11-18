import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart'; // 실제 주소 변환에 필요
import 'ambulance_data.dart'; // 위에서 정의한 DTO 파일 경로

// DTO 파일에 정의된 상수 (가정)
const List<String> kCompanyHeaders = ['업체명', '주소', '연락처'];
const List<String> kOfficerHeaders = ['담당과', '담당팀', '연락처'];


class Ambulance extends StatefulWidget {
  const Ambulance({super.key});

  @override
  State<Ambulance> createState() => _AmbulanceState();
}

class _AmbulanceState extends State<Ambulance> {
  // 현재 위치 상태
  String _currentLocation = "위치 정보를 불러오는 중...";
  // 💡 필터링의 주 기준: 선택된 시/도 (광역자치단체)
  String? _selectedProvince;
  // 선택된 구/군 (참고용, 필수 필터 기준 아님)
  String? _selectedRegion;

  // API로부터 로드된 전체 데이터
  List<AmbulanceDto> _allAmbulances = [];
  // 현재 화면에 표시할 필터링된 데이터
  List<AmbulanceDto> _filteredAmbulances = [];

  // 처리 기관 정보 (시/도별로 고정)
  String _department = '정보 없음';
  String _team = '정보 없음';
  String _agencyContact = '정보 없음';

  // API 클라이언트, Dio 인스턴스에 충분한 타임아웃 시간(예: 5초)을 설정합니다.
  final Dio _dio = Dio( BaseOptions(
    connectTimeout: const Duration(seconds: 5),// 연결 시간 초과를 5초로 설정
    receiveTimeout: const Duration(seconds: 3),// 데이터 수신 시간 초과 설정
  )

  );
  final String _apiUrl = "http://192.168.40.61:8080/api/ambulance/all";


  @override
  void initState() {
    super.initState();
    // 위치 정보 획득 및 데이터 로드를 동시에 시작
    _determinePosition();
    _loadData();
  }

  // ------------------------------------------------------------------
  //  1. 위치 정보 획득 및 업데이트 (_determinePosition)
  // ------------------------------------------------------------------
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // ... (권한 및 서비스 체크 로직은 동일)
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
      // Position position = await Geolocator.getCurrentPosition();
      // 실제로는 position.latitude와 position.longitude를 주소로 변환하여 사용해야 함.
      if (mounted) { // 💡 mounted 확인
        setState(() {
          _currentLocation = '인천 부평구 부평동';
          // 💡 현재 위치 기반으로 초기 시도 설정
          _selectedProvince = '인천';
          _selectedRegion = '부평구'; // (참고용으로 설정)
        });
        // 데이터 로드가 완료되었을 수도 있으므로 필터 재적용
        _applyFilter();
      }
    } catch (e) {
      if( mounted ) { // 💡 mounted 확인
        setState(() => _currentLocation = '위치 획득에 실패했습니다.');
      }
    }
  }

  // ------------------------------------------------------------------
  //  2. 백엔드 API로부터 전체 데이터 로드 (_loadData)
  // ------------------------------------------------------------------
  Future<void> _loadData() async {
    try {
      final response = await _dio.get(_apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;

        // 💡 mounted 확인: 위젯이 여전히 활성화된 상태인지 확인합니다.
        if (mounted) {
          setState(() {
            _allAmbulances =
                jsonList.map((json) => AmbulanceDto.fromJson(json)).toList();
          });
          // 데이터 로드 완료 후 현재 설정된 지역 기준으로 필터링 적용
          _applyFilter();
        }
      }
    } catch (e) {
      print("API 호출 오류: $e");
      // 💡 데이터 로드 실패 시 사용자에게 알림 필요
    }
  }

  // ------------------------------------------------------------------
  //  3. 지역 필터링 적용 및 화면 업데이트 (_applyFilter)
  // ------------------------------------------------------------------
  void _applyFilter() {
    setState(() {
      // 1. 시/도 필터링 (주 기준)
      if (_selectedProvince == null || _selectedProvince!.isEmpty) {
        _filteredAmbulances = _allAmbulances;
      } else {
        // 💡 수정됨: 선택된 '시/도' (province)를 기준으로 필터링
        _filteredAmbulances = _allAmbulances
            .where((item) => item.province == _selectedProvince)
            .toList();
      }

      // 2. 감독 기관 정보 업데이트 (필터링 기준인 시/도에 따라 정보 업데이트)
      if (_selectedProvince != null && _selectedProvince!.isNotEmpty) {
        // 시/도 기준으로 전체 데이터에서 감독 기관 정보 추출 (첫 번째 항목 기준)
        final agencyInfo = _allAmbulances
            .firstWhere(
              (item) => item.province == _selectedProvince,
          orElse: () => AmbulanceDto(
            province: '', region: '', address: '', companyName: '', special: '', general: '', contact: '',
            department: '정보 없음', team: '정보 없음', officerContact: '정보 없음',
          ),
        );

        _department = agencyInfo.department;
        _team = agencyInfo.team;
        // _agencyContact는 해당 시/도의 담당과 연락처를 사용
        _agencyContact = agencyInfo.officerContact.isNotEmpty
            ? agencyInfo.officerContact
            : '정보 없음';
      } else {
        // 필터링 기준이 없을 경우 초기화
        _department = '정보 없음';
        _team = '정보 없음';
        _agencyContact = '정보 없음';
      }
    });
  }

  // ------------------------------------------------------------------
  //  4. 지역 선택 다이얼로그 (_showRegionSelectionDialog)
  // ------------------------------------------------------------------
  void _showRegionSelectionDialog() async {
    // 💡 지역 목록 추출: _allAmbulances가 비어있으면 provinces도 비어있어 지역 목록이 안 나옴.
    final List<String> provinces = _allAmbulances
        .map((e) => e.province)
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // 💡 다이얼로그에서 시/도 선택
    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('시/도 선택'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // '전체' 옵션 추가 (null 반환)
                ListTile(
                  title: const Text('전체 지역'),
                  onTap: () => Navigator.pop(context, null),
                ),
                // 💡 지역 목록 출력
                if (provinces.isEmpty)
                  const ListTile(title: Text('지역 데이터를 불러오지 못했습니다.')),

                ...provinces.map((province) => ListTile(
                  title: Text(province),
                  onTap: () => Navigator.pop(context, province),
                )),
              ],
            ),
          ),
        );
      },
    );

    // 💡 수정됨: 선택된 시/도에 따라 상태 업데이트 및 필터 적용
    if (selected != null) {
      setState(() {
        _selectedProvince = selected;
      });
      _applyFilter();
    } else if (selected == null) {
      setState(() {
        _selectedProvince = null; // '전체 지역' 선택 시 필터 해제
      });
      _applyFilter();
    }
  }




  // ------------------------------------------------------------------
  //  --- 위젯 구성 요소 ---
  // ------------------------------------------------------------------

  // 상단 현재 위치 및 버튼 (수정: 아이콘 및 버튼 텍스트)
  Widget _buildHeader() {
    // 💡 버튼의 둥근 테두리 스타일 정의
    final ButtonStyle roundedButtonStyle = ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('현재위치', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            // 💡 현재 위치 아이콘 추가
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 24),
              const SizedBox(width: 4),
              Text(_currentLocation, style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 💡 FlexColumnWidth(1.0) 대신 Expanded(flex: 1)로 절반 크기 유지
              Expanded(
                flex: 1, // 절반 크기
                child: ElevatedButton(
                  onPressed: _showRegionSelectionDialog,
                  style: roundedButtonStyle, // 둥근 사각 스타일 적용
                    child: Text(_selectedProvince ?? '시/도 선택'),
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

  // 업체 현황 테이블 (수정: 업체명 출력 및 주소에 구/군 추가)
  Widget _buildCompanyTable() {
    final String currentFilterText = _selectedProvince ?? '전체';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$currentFilterText 민간 구급차 현황', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  // 💡 수정됨: "item.companyName" (문자열) -> item.companyName (변수)
                  _buildTableCell(item.companyName, alignment: Alignment.centerLeft),
                  // 💡 수정됨: 주소에 구/군을 함께 출력
                  _buildTableCell('${item.region}, ${item.address}', alignment: Alignment.centerLeft),
                  _buildTableCell(item.contact, alignment: Alignment.center),
                ],
              )),
              if (_filteredAmbulances.isEmpty)
                TableRow(
                    children: [
                      // 빈 데이터 시 Colspan 역할을 하는 셀 추가
                      _buildTableCell("데이터가 없습니다.", alignment: Alignment.center),
                      _buildTableCell("", alignment: Alignment.center),
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
          Image.asset(
            'assets/images/ambulance_price.PNG',
            fit: BoxFit.fitWidth,
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

  // 불만 처리 기관 (상태 변수 사용)
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
                  // 💡 상태 변수 사용
                  _buildTableCell(_department, alignment: Alignment.center),
                  _buildTableCell(_team, alignment: Alignment.center),
                  _buildTableCell(_agencyContact, alignment: Alignment.center),
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
      color: isHeader ? Colors.black : (isKey ? Colors.black : Colors.black),
      fontSize: 13,
    );

    final Widget cellContent = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: alignment,
        child: Text(text, style: style, textAlign: TextAlign.center),
      ),
    );
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
    );
  }
}