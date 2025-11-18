// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:geolocator/geolocator.dart';
// import 'ambulance_data.dart'; // 위에서 정의한 DTO 파일 경로
//
//
// class Ambulance extends StatefulWidget {
//   const Ambulance({super.key});
//
//   @override
//   State<Ambulance> createState() => _AmbulanceState();
// }
//
// class _AmbulanceState extends State<Ambulance> {
//   // 현재 위치 상태
//   String _currentLocation = "위치 정보를 불러오는 중...";
//   // 💡 선택된 시/도 (광역자치단체) - 필터링의 주 기준
//   String? _selectedProvince;
//   // 선택된 구/군 (참고용, 필수 필터 기준 아님)
//   String? _selectedRegion;
//
//   // API로부터 로드된 전체 데이터
//   List<AmbulanceDto> _allAmbulances = [];
//   // 현재 화면에 표시할 필터링된 데이터
//   List<AmbulanceDto> _filteredAmbulances = [];
//
//   // 처리 기관 정보 (시/도별로 고정)
//   String _department = '정보 없음';
//   String _team = '정보 없음';
//   String _agencyContact = '정보 없음';
//
//   // API 클라이언트
//   final Dio _dio = Dio();
//   final String _apiUrl = "http:// 192.168.40.61:8080/api/ambulance/all"; // 실제 서버 주소로 변경하세요.
//
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     // 💡 _determinePosition()이 _loadData()보다 먼저 시작되어야 초기 지역 설정이 가능합니다.
//     _determinePosition();
//   }
//
//   // ... (_determinePosition() 함수는 현재 위치 기반으로 _selectedProvince, _selectedRegion을 설정하는 로직으로 유지)
//
//   /// 1. 위치 정보 획득 및 현재 위치 업데이트
//   Future<void> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       setState(() => _currentLocation = '위치 서비스를 켜주세요.');
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() => _currentLocation = '위치 권한이 거부되었습니다.');
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       setState(() => _currentLocation = '위치 권한을 영구적으로 허용해야 합니다.');
//       return;
//     }
//
//     try {
//       Position position = await Geolocator.getCurrentPosition();
//       // 실제 위치 정보 -> 주소 변환 (Geocoder) 로직은 생략하고 샘플 텍스트 사용
//       setState(() {
//         // 실제로는 position.latitude와 position.longitude를 주소로 변환하여 사용해야 함.
//         _currentLocation = '인천 부평구 부평동';
//         // 💡 샘플 위치를 기반으로 초기 시도/구군 설정
//         // 실제 구현 시 Geocoder를 사용해 주소에서 '시/도'와 '구/군'을 추출해야 합니다.
//         _selectedProvince = '인천';
//       });
//       // 데이터 로드 완료 후 적용해야 하므로, _loadData() 완료를 기다린 후 호출하도록 로직 조정이 필요합니다.
//       // 현재는 _loadData()와 비동기로 진행되므로, _loadData() 내부에서 다시 _applyFilter()를 호출하도록 유지합니다.
//       _applyFilter(); // 위치 획득 후 데이터 필터링 적용
//     } catch (e) {
//       setState(() => _currentLocation = '위치 획득에 실패했습니다.');
//     }
//   }
//
//   /// 3. 지역 필터링 적용 및 화면 업데이트
//   void _applyFilter() {
//     setState(() {
//       // 1. 시/도 필터링 (주 기준)
//       if (_selectedProvince == null || _selectedProvince!.isEmpty) {
//         _filteredAmbulances = _allAmbulances;
//       } else {
//         // 💡 선택된 '시/도'를 기준으로 필터링
//         _filteredAmbulances = _allAmbulances
//             .where((item) => item.region == _selectedRegion)
//             .toList();
//       }
//       // 2. 감독 기관 정보 업데이트 (필터링 기준인 시/도에 따라 정보 업데이트)
//       if (_selectedProvince != null && _selectedProvince!.isNotEmpty) {
//         // 시/도 기준으로 전체 데이터에서 감독 기관 정보 추출 (첫 번째 항목 기준)
//         final agencyInfo = _allAmbulances
//             .firstWhere(
//               (item) => item.province == _selectedProvince,
//           orElse: () => AmbulanceDto(
//             province: '', region: '', address: '', companyName: '', special: '', general: '', contact: '',
//             department: '정보 없음', team: '정보 없음', officerContact: '정보 없음',
//           ),
//         );
//
//         _department = agencyInfo.department;
//         _team = agencyInfo.team;
//         // _agencyContact는 해당 시/도의 담당과 연락처를 사용
//         _agencyContact = agencyInfo.officerContact.isNotEmpty
//             ? agencyInfo.officerContact
//             : '정보 없음';
//       } else {
//         // 데이터가 없거나 지역 미선택 시 초기화
//         _department = '정보 없음';
//         _team = '정보 없음';
//         _agencyContact = '정보 없음';
//       }
//     });
//   }
//
//   /// 4. 지역 선택 다이얼로그 (시/도만 선택)
//   void _showRegionSelectionDialog() async {
//     // 💡 시/도 목록 추출
//     final List<String> provinces = _allAmbulances
//         .map((e) => e.province)
//         .where((p) => p.isNotEmpty)
//         .toSet()
//         .toList()
//       ..sort();
//
//     // 💡 다이얼로그에서 시/도 선택
//     final selectedProvince = await showDialog<String>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('시/도 선택'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // '전체' 옵션 추가
//                 ListTile(
//                   title: const Text('전체 지역'),
//                   onTap: () => Navigator.pop(context, null),
//                 ),
//                 ...provinces.map((province) => ListTile(
//                   title: Text(province),
//                   onTap: () => Navigator.pop(context, province),
//                 )),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//
//     if (selected != null) {
//       // '전체 지역'을 선택했을 때는 null이 넘어오므로 처리
//       setState(() {
//         _selectedProvince = selected;
//         // 구/군 정보는 현재 위치 기반 정보로 유지하거나 초기화할 수 있지만,
//         // 필터링 주 기준이 아니므로 여기서는 시/도만 변경합니다.
//       });
//       _applyFilter();
//     } else if (selected == null) {
//       setState(() {
//         _selectedProvince = null; // '전체 지역' 선택 시 필터 해제
//       });
//       _applyFilter();
//     }
//   }
//
//
//   // --- 위젯 구성 요소 ---
//
//   // 상단 현재 위치 및 버튼
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       color: Colors.white,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('현재위치', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 4),
//           Text(_currentLocation, style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: _showRegionSelectionDialog,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('지역선택'),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // TODO: 이송 버튼 액션 구현
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('이동'),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Text('자료출처: 보건복지부 구급차_관리운영_지침(제4판)', style: TextStyle(fontSize: 12, color: Colors.grey)),
//         ],
//       ),
//     );
//   }
//
//   // 업체 현황 테이블 (업체명, 주소, 연락처)
//   Widget _buildCompanyTable() {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: Column(```````````````````````````````````````````````
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//         const Text('업체 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//     const SizedBox(height: 8),
//     Table(
//     border: TableBorder.all(color: Colors.grey.shade300),
//     columnWidths: const {
//     0: FlexColumnWidth(1.5), // 업체명
//     1: FlexColumnWidth(3.0), // 주소
//     2: FlexColumnWidth(1.5), // 연락처
//     },
//     children: [
//     // 헤더 행
//     TableRow(
//     decoration: BoxDecoration(color: Colors.grey.shade200),
//     children: kCompanyHeaders.map((header) =>
//     _buildTableCell(header, isHeader: true, alignment: Alignment.center))
//         .toList(),
//     ),
//     // 데이터 행
//     ..._filteredAmbulances.map((item) => TableRow(
//     children: [
//     _buildTableCell("item.companyName", alignment: Alignment.centerLeft),
//     _buildTableCell(item.address, alignment: Alignment.centerLeft),
//     _buildTableCell(item.contact, alignment: Alignment.center),
//     ],
//     )),
//     if (_filteredAmbulances.isEmpty)
//     TableRow(
//     children: [
//     // 💡 1. 메시지를 담는 셀
//     _buildTableCell("데이터가 없습니다.", alignment: Alignment.center),
//     // 💡 2. 빈 셀 (Colspan 역할을 대신)
//     _buildTableCell("", alignment: Alignment.center),
//     // 💡 3. 빈 셀 (Colspan 역할을 대신)
//     _buildTableCell("", alignment: Alignment.center),
//     ]
//     )
//     ],
//     ),
//     ],
//     ),
//     );
//     }
//
//   // 이송 처치료 기준 (고정 데이터)
//   Widget _buildFeeTable() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ----------------------------------------------------
//           // 1. 이미지를 assets 폴더에 저장하고 pubspec.yaml에 경로를 등록해야 합니다.
//           Image.asset(
//             'assets/images/ambulance_price.PNG', // 이미지 경로를 실제 경로로 수정하세요.
//             fit: BoxFit.fitWidth, // 너비에 맞게 조절
//           ),
//           // ----------------------------------------------------
//           const SizedBox(height: 12),
//           const Text(
//             '이송처치료는 구급차 내에 장착된 미터기에 의해 계산되며, 영수증이 발급됩니다.',
//             style: TextStyle(fontSize: 14),
//           ),
//           const SizedBox(height: 12),
//           const Divider(),
//           const Text(
//             '아래의 경우 등과 같이 이송처치료 외의 추가비용을 요구하는 것은 불법입니다.',
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//           ),
//           const Text('> 왕복, 시외이유로 추가 비용을 요구하는 경우 -> 불법', style: TextStyle(color: Colors.grey)),
//           const Text('> 의료장비 사용료, 처치비용, 의약품 사용 등의 추가 비용을 요구하는 경우 -> 불법', style: TextStyle(color: Colors.grey)),
//           const Text('> 카드수수료, 보호자 합승비, 대기비 등의 추가 비용을 요구하는 경우 -> 불법', style: TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }
//
//   // 불만 처리 기관
//   Widget _buildProcessingAgency() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             '탑승하신 구급차 이용과 관련한 불편사항 처리기관',
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Table(
//             border: TableBorder.all(color: Colors.grey.shade300),
//             columnWidths: const {
//               0: FlexColumnWidth(2.0),
//               1: FlexColumnWidth(2.0),
//               2: FlexColumnWidth(2.0),
//             },
//             children: [
//               // 헤더 행
//               TableRow(
//                 decoration: BoxDecoration(color: Colors.grey.shade200),
//                 children: kOfficerHeaders.map((header) =>
//                     _buildTableCell(header, isHeader: true, alignment: Alignment.center))
//                     .toList(),
//               ),
//               // 데이터 행
//               TableRow(
//                 children: [
//                   _buildTableCell(_department.isNotEmpty ? _department : '정보 없음', alignment: Alignment.center),
//                   _buildTableCell(_team.isNotEmpty ? _team : '정보 없음', alignment: Alignment.center),
//                   _buildTableCell(_agencyContact.isNotEmpty ? _agencyContact : '정보 없음', alignment: Alignment.center),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 공통 테이블 셀 위젯
//   Widget _buildTableCell(String text, {bool isHeader = false, bool isKey = false, Alignment alignment = Alignment.center, int colspan = 1}) {
//     final TextStyle style = TextStyle(
//       fontWeight: isHeader || isKey ? FontWeight.bold : FontWeight.normal,
//       color: isHeader ? Colors.white : (isKey ? Colors.black : Colors.black),
//       fontSize: 13,
//     );
//
//     // colspan 처리는 TableCell을 Column으로 감싸서 구현 (단순화)
//     final Widget cellContent = Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Align(
//         alignment: alignment,
//         child: Text(text, style: style, textAlign: TextAlign.center),
//       ),
//     );
//
//     if (colspan > 1) {
//       return TableCell(child: cellContent); // 실제 ColumnSpan 로직이 아니므로 주의
//     }
//     return TableCell(child: cellContent);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('사설 구급차 이용 안내', style: TextStyle(fontSize: 18)),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildHeader(),
//             const Divider(height: 1, thickness: 1, color: Colors.grey),
//             _buildCompanyTable(),
//             _buildFeeTable(),
//             _buildProcessingAgency(),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//       // 네비게이션 바 (요청에 따라 생략)
//       // bottomNavigationBar: const BottomNavBar(),
//     );
//   }
// }