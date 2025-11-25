// sex_crime_filter_modal.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

final dio = Dio();

// 🚨 데이터 호출 로직을 위해 _fetchAndShowMarkers 함수가 있는 KakaoMapState 인스턴스가 필요합니다.
// 여기서는 간소화를 위해 onFilterApplied 콜백 함수만 정의합니다.
// 실제 구현 시에는 이 콜백을 통해 KakaoMapState의 데이터를 업데이트해야 합니다.
typedef void OnFilterApplied(String sido, String sigungu, String dong);

class SexCrimeFilterModal extends StatefulWidget {
  final Map<String, int> initialData; // 초기 전체 데이터 (예: {인천: 223, 부평구: 28, 부평동: 7})
  final OnFilterApplied onFilterApplied; // 필터 적용 시 호출할 함수 (예: 지도 데이터 업데이트)

  const SexCrimeFilterModal({
    super.key,
    required this.initialData,
    required this.onFilterApplied,
  });

  @override
  _SexCrimeFilterModalState createState() => _SexCrimeFilterModalState();
}

class _SexCrimeFilterModalState extends State<SexCrimeFilterModal> {
  // 3단계 필터링에 사용할 선택된 값
  String? _selectedSido;
  String? _selectedSigungu;
  String? _selectedDong;

  // 필터링 옵션 (실제 데이터는 API로 받아와야 하지만, 예시를 위해 하드코딩)
  // 실제 구현 시 서버에서 구/동 목록을 미리 받아와야 합니다.
  //final List<String> _cities = ['인천', '서울', '경기'];
  final List<String> sidoList = [ '인천' ];
  final Map<String, List<String>> sigunguMap = {
    '인천': ['강화군','계양구','남동구','동구', '미추홀구','부평구', '서구','연수구','옹진군','중구'],
    //'서울': ['강남구', '송파구', '종로구'],
    //'경기': ['수원시', '성남시'],
  };
  final Map<String, List<String>> dongMap = {
    '강화군': ['강화읍', '교동면', '길상면', '내가면', '불은면', '삼산면', '서도면', '선원면', '송해면', '양도면', '양사면', '하점면', '하도면'],
    '계양구': ['갈현동', '계산동', '귤현동', '노오지동', '다남동', '동양동', '둑실동', '목상동', '박촌동', '방축동', '병방동', '상야동', '서운동',
              '선주지동', '오류동','용종동', '이화동','임학동', '작전동', '장기동', '평동', '하야동', '효성동'],
    '남동구': ['간석동', '고잔동', '구월동', '남촌동', '논현동', '도림동', '만수동', '서창동', '수산동', '운연동', '장수동'],
    '동구': ['금곡동', '만석동', '송림동', '송현동', '창영동', '화수동', '화평동'],
    '미추홀구': ['관교동', '도화동', '문학동', '숭의동', '용현동', '주안동', '학익동'],
    '부평구': ['갈산동', '구산동', '부개동', '부평동', '산곡동', '삼산동', '십정동', '일신동','청천동'],
    '서구': ['가정동', '가좌동', '검암동', '경서동', '공촌동', '금곡동', '당하동', '대곡동', '마전동', '백석동', '불로동', '석남동',
             '시천동', '신현동', '심곡동', '연희동', '오류동', '왕길동', '원당동','원창동', '청라동'],
    '연수구': ['동춘동', '선학동', '송도동', '연수동', '옥련동', '청학동'],
    '옹진군': ['대청면', '덕적면', '백령면', '북도면', '연평면', '영흥면', '자월면'],
    '중구': ['경동', '관동1가', '관동2가', '관동3가', '남북동', '내동', '답동', '덕교동','도원동', '무의동', '북성동1가', '북성동2가', '북성동3가',
    '사동', '선린동', '선화동', '송월동1가','송월동2가', '송월동3가', '송학동1가', '송학동2가', '송학동3가', '신생동', '신포동',
           '신흥동1가', '신흥동2가', '신흥동3가','용동', '운남동', '운북동', '운서동', '유동', '율목동', '을왕동', '인현동', '전동', '중산동',
           '중앙동1가', '중앙동2가', '중앙동3가', '중앙동4가', '항동1가', '항동2가', '항동3가', '항동4가', '항동5가', '항동6가','항동7가',
           '해안동1가', '해안동2가', '해안동3가', '해안동4가']
  };

  final String kakaoJsKey = '9eb4f86b6155c2fa2f5dac204d2cdb35';
  final String serverBaseUrl = 'http://192.168.40.61:8080';

  Map<String, int> _filteredResult = {}; // 필터링 결과 저장용 변수

  @override
  void initState() {
    super.initState();
    // 초기에는 전체 데이터 표시
    _filteredResult = widget.initialData;
  }

  // 필터 적용 로직 (실제 API 호출을 가정)
  void _applyFilter() {
    // 1. 선택된 시/구/동 값을 API 호출에 필요한 형태로 조합
    final sido = _selectedSido ?? '';
    final sigungu = _selectedSigungu ?? '';
    final dong = _selectedDong ?? '';

    // 2. 외부로 선택된 필터 값을 전달하여 마커를 다시 로드하도록 요청
    //widget.onFilterApplied(sido, sigungu, dong);

    print( sido );
    print( sigungu );
    print( dong );


    // 3. (옵션) 모달 내에 필터링된 인원수를 보여주기 위해 API를 호출하고 결과를 업데이트

    void entry() async{
      try{
        final response = await dio.get("http://192.168.40.61:8080/api/sexcrime/filter");
        final data = await response.data;
        print( data );
        print('--------------------------------------------------');

      }catch(e) { print(e); }
    }

    // 여기서는 UI 예시를 위해 임시로 하드코딩된 값을 업데이트합니다.
    setState(() {
      if (sido.isNotEmpty && sigungu.isNotEmpty) {
        _filteredResult = {'${sido} ${sigungu} 인원수': 15};
      } else {
        _filteredResult = widget.initialData;
      }
    });

    // 모달 닫기
    //Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 선택된 구 목록과 동 목록을 동적으로 가져옵니다.
    final currentSigungus = _selectedSido != null ? sigunguMap[_selectedSido] : null;
    final currentDongs = _selectedSigungu != null ? dongMap[_selectedSigungu] : null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '현재 위치 성범죄자 등록 현황',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),

          // --- 1. 지역 필터 드롭다운 ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ 시 (Sido)
              _buildDropdown('시', sidoList, _selectedSido, (newValue) {
                setState(() {
                  _selectedSido = newValue;
                  _selectedSigungu = null; // 상위 변경 시 하위 초기화
                  _selectedDong = null;
                });
              }),
              // ✅ 구/군 (Sigungu)
              _buildDropdown('구/군', currentSigungus, _selectedSigungu, (newValue) {
                setState(() {
                  _selectedSigungu = newValue;
                  _selectedDong = null; // 상위 변경 시 하위 초기화
                });
              }),
              // ✅ 동/면 (Dong)
              _buildDropdown('동/면', currentDongs, _selectedDong, (newValue) {
                setState(() {
                  _selectedDong = newValue;
                });
              }),
            ],
          ),
          const SizedBox(height: 20),

          // --- 2. 현재 인원수 정보 ---
          ..._filteredResult.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '${entry.key} : ${entry.value}명',
              style: const TextStyle(fontSize: 15),
            ),
          )),
          const SizedBox(height: 10),

          const Text(
            '자료 출처: 여성가족부 성범죄자 알림e',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // --- 3. 필터 적용 버튼 ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('검색 및 확인'),
            ),
          ),
        ],
      ),
    );
  }

  // 드롭다운 위젯 빌더
  Widget _buildDropdown(String label, List<String>? items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: DropdownButtonFormField<String>(
          // `items`가 null이거나 비어있으면 드롭다운을 비활성화하고 힌트를 표시합니다.
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            // 활성화/비활성화 상태를 테두리 색상으로 시각화합니다.
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: items == null || items.isEmpty ? Colors.grey.shade300 : Colors.grey),
            ),
          ),
          value: selectedValue,
          isExpanded: true,
          hint: Text(label),
          // items가 없으면 null을 전달하여 비활성화합니다.
          items: items?.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          // items가 null이거나 비어있으면 onChanged를 null로 만들어 비활성화합니다.
          onChanged: items == null || items.isEmpty ? null : onChanged,
        ),
      ),
    );
  }
}