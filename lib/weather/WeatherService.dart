import 'dart:convert';
// HTTP 통신을 위해 'package:http/http.dart'가 필요합니다.
// 실제 사용 시 pubspec.yaml에 'http' 패키지를 추가하고 아래 주석을 해제하세요.
// import 'package:http/http.dart' as http;

import 'package:moveon_app/weather/WeatherModel.dart';

class WeatherService {
  // Spring Boot 서버의 IP 주소와 포트, 그리고 컨트롤러 경로를 설정하세요.
  final String baseUrl = 'http://localhost:8080';

  // 위치 기반으로 백엔드 API를 호출하여 WeatherData를 반환하는 함수
  Future<WeatherData> fetchWeatherData(double lat, double lon) async {
    final url = Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon');

    try {
      // 실제 HTTP 요청 (http 패키지 설치 후 주석 해제)
      /* final response = await http.get(url);

      if (response.statusCode == 200) {
        final rawJson = jsonDecode(response.body);

        // TODO: rawJson에서 필요한 데이터를 추출하여 WeatherData.fromJson()에 맞게 재구성해야 합니다.
        // Spring Boot에서 파싱 후 통합된 최종 JSON을 반환하도록 백엔드를 수정하는 것이 가장 좋습니다.

        // 현재는 Mock 데이터를 사용하여 UI 연결만 확인합니다.
        return WeatherData.fromJson({
          'location': '강남역 근처',
          'currentTemp': '25°C',
          'weatherCondition': '맑음',
          'fineDust': '35 ㎍/㎥ (보통)',
          'ultrafineDust': '15 ㎍/㎥ (좋음)',
          'uvIndex': '6',
        });

      } else {
        throw Exception('API 호출 실패: 상태 코드 ${response.statusCode}');
      }
      */

      // Mock 데이터 로딩 (통신 로직 미사용 시)
      await Future.delayed(const Duration(seconds: 2));
      return WeatherData(
        location: '서울시 강남구 (Mock Data)',
        currentTemp: '25°C',
        weatherCondition: '맑음',
        fineDust: '35 ㎍/㎥ (보통)',
        ultrafineDust: '15 ㎍/㎥ (좋음)',
        uvIndex: '6',
      );

    } catch (e) {
      // 실제 예외 처리 시 로그를 남기거나 사용자에게 더 자세한 오류 메시지를 제공해야 합니다.
      throw Exception("데이터를 가져오는 중 오류 발생: ${e.toString()}");
    }
  }
}