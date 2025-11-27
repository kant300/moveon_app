import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart'; // 💡 url_launcher 패키지 임포트
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
  )); // 💡 닫는 괄호 수정
  final String _apiUrl = "http://10.95.125.46:8080/api/ambulance/all";


  @override
  void initState() {
    super.initState();
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
      if (mounted) setState(() => _currentLocation = '위치 서비스를 켜주세요.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _currentLocation = '위치 권한이 거부되었습니다.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _currentLocation = '위치 권한을 영구적으로 허용해야 합니다.');
      return;
    }

    try {
      // Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLocation = '인천 부평구 부평동';
          _selectedProvince = '인천';
          _selectedRegion = '부평구';
        });
        _applyFilter();
      }
    } catch (e) {
      // 💡 오류 수정: 위치 획득 실패 시 상태 업데이트만 수행
      if (mounted) {
        setState(() => _currentLocation = '위치 획득에 실패했습니다.');
      }
    }
  } // 💡 닫는 중괄호 추가

  // ------------------------------------------------------------------
  //  2. 백엔드 API로부터 전체 데이터 로드 (_loadData)
  // ------------------------------------------------------------------
  Future<void> _loadData() async {
    try {
      final response = await _dio.get(_apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
         print( jsonList );

        if (mounted) {
          setState(() {
            _allAmbulances =
                jsonList.map((json) => AmbulanceDto.fromJson(json)).toList();
          });
          _applyFilter();
        }
      }
    } catch (e) {
      print("API 호출 오류: $e");
    }
  }

  // ------------------------------------------------------------------
  //  3. 지역 필터링 적용 및 화면 업데이트 (_applyFilter)
  // ------------------------------------------------------------------
  void _applyFilter() {
    setState(() {
      if (_selectedProvince == null || _selectedProvince!.isEmpty) {
        _filteredAmbulances = _allAmbulances;
      } else {
        _filteredAmbulances = _allAmbulances
            .where((item) => item.province == _selectedProvince)
            .toList();
      }

      // 2. 감독 기관 정보 업데이트 (필터링 기준인 시/도에 따라 정보 업데이트)
      if (_selectedProvince != null && _selectedProvince!.isNotEmpty) {
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
        _agencyContact = agencyInfo.officerContact.isNotEmpty
            ? agencyInfo.officerContact
            : '정보 없음';
      } else {
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
    final List<String> provinces = _allAmbulances
        .map((e) => e.province)
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('시/도 선택'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('전체 지역'),
                  onTap: () => Navigator.pop(context, null),
                ),
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

    if (selected != null) {
      setState(() {
        _selectedProvince = selected;
      });
      _applyFilter();
    } else if (selected == null) {
      setState(() {
        _selectedProvince = null;
      });
      _applyFilter();
    }
  }

  // 💡 전화 연결 로직 (_launchUrl)
  Future<void> _launchUrl(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('전화 연결에 실패했습니다: $phoneNumber')),
        );
      }
    }
  }


  // ------------------------------------------------------------------
  //  --- 위젯 구성 요소 ---
  // ------------------------------------------------------------------

  // 상단 현재 위치 및 버튼
  Widget _buildHeader() {
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
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 24),
              const SizedBox(width: 4),
              Text(_currentLocation, style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: _showRegionSelectionDialog,
                  style: roundedButtonStyle,
                  child: Text(_selectedProvince ?? '시/도 선택'),
                ),
              ),
              // '이동' 버튼이 없으므로 주석 처리하거나 제거 (원래 코드에서는 있었음)
              // const SizedBox(width: 8),
              // Expanded(
              //   flex: 1,
              //   child: ElevatedButton(
              //     onPressed: () { /* TODO: 이송 버튼 액션 구현 */ },
              //     style: roundedButtonStyle,
              //     child: const Text('이동'),
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 12),
          const Text('자료출처: 보건복지부 구급차_관리운영_지침(제4판)', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // 업체 현황 테이블
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
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(3.0),
              2: FlexColumnWidth(1.5),
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
                  _buildTableCell(item.companyName, alignment: Alignment.centerLeft),
                  _buildTableCell('${item.region} ${item.address}', alignment: Alignment.centerLeft),
                  // 💡 수정됨: _buildTapableTableCell 사용
                  _buildTapableTableCell(
                    item.contact,
                    alignment: Alignment.center,
                    onTap: () => _launchUrl(item.contact),
                  ),
                ],
              )),
              if (_filteredAmbulances.isEmpty)
                TableRow(
                    children: [
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

  // 💡 탭 가능한 공통 테이블 셀 위젯 (전화 연결용)
  Widget _buildTapableTableCell(String text, {required Alignment alignment, required VoidCallback onTap}) {
    const TextStyle style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 13,
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );

    final Widget cellContent = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: alignment,
        child: Text(text, style: style, textAlign: TextAlign.center),
      ),
    );

    return TableCell(
      child: GestureDetector(
        onTap: onTap,
        child: cellContent,
      ),
    );
  }

  // 이송 처치료 기준 (고정 데이터)
  Widget _buildFeeTable() {
    // ... (기존 코드와 동일)
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
                  _buildTableCell(_department, alignment: Alignment.center),
                  _buildTableCell(_team, alignment: Alignment.center),
                  _buildTapableTableCell(
                      _agencyContact,
                      alignment: Alignment.center,
                      // '정보 없음'이 아닐 때만 전화 연결 로직 실행
                      onTap: _agencyContact == '정보 없음'
                          ? () {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('유효한 연락처 정보가 없습니다.')));
                          }
                        }
                            : () => _launchUrl(_agencyContact),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 공통 테이블 셀 위젯
  Widget _buildTableCell(String text, {bool isHeader = false, bool isKey = false, Alignment alignment = Alignment.center}) { // 💡 onTap 매개변수 제거
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
        title: const Text('민간 구급차 이용 안내', style: TextStyle(fontSize: 18)),
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