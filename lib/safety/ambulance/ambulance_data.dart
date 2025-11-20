

/// 백엔드 AmbulanceDto와 매칭되는 모델
class AmbulanceDto {
  // 💡 한글 변수명을 영문으로 변경
  final String province;       // 시도
  final String region;         // 구군
  final String address;        // 주소
  final String companyName;    // 업체명
  final String special;        // 특수
  final String general;        // 일반
  final String contact;        // 연락처
  final String department;     // 담당과
  final String team;           // 담당팀
  final String officerContact; // 담당자연락처

  AmbulanceDto({
    required this.province,
    required this.region,
    required this.address,
    required this.companyName,
    required this.special,
    required this.general,
    required this.contact,
    required this.department,
    required this.team,
    required this.officerContact,
  });

  factory AmbulanceDto.fromJson(Map<String, dynamic> json) {
    return AmbulanceDto(
      // 💡 필드명은 영문으로, JSON 키는 백엔드와 맞춘 한글 키로 유지
      province: json['시도'] ?? '',
      region: json['구군'] ?? '',
      address: json['주소'] ?? '',
      companyName: json['업체명'] ?? '',
      special: json['특수'] ?? '',
      general: json['일반'] ?? '',
      contact: json['연락처'] ?? '',
      department: json['담당과'] ?? '',
      team: json['담당팀'] ?? '',
      officerContact: json['담당자연락처'] ?? '',
    );
  }
}
/// 업체 현황 테이블 헤더
const List<String> kCompanyHeaders = ['업체명', '주소', '연락처'];

/// 이송 처치료 기준 (고정 데이터)
const Map<String, List<String>> kFeeData = {
'기본요금 (이송거리 10km 이내)': ['30,000원', '75,000원'],
'추가요금 (이송거리 1km 초과)': ['1,000원/1km', '1,300원/1km'],
'부가요금 (응급구조사 활용 시)': ['15,000원', 'X'],
'할증요금 (00:00~04:00)': ['개별 및 추가요금에 각각 20% 가산'],
};

/// 담당과/팀 헤더
const List<String> kOfficerHeaders = ['담당과', '담당팀', '연락처'];