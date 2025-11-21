import 'package:flutter/material.dart';

// 백엔드에서 받아올 최종 데이터를 담는 모델입니다.
class WeatherData {
  final String location;
  final String currentTemp;
  final String weatherCondition;
  final String fineDust;
  final String ultrafineDust;
  final String uvIndex;

  WeatherData({
    required this.location,
    required this.currentTemp,
    required this.weatherCondition,
    required this.fineDust,
    required this.ultrafineDust,
    required this.uvIndex,
  });

  // 백엔드에서 받은 JSON (Map<String, dynamic>)을 Dart 객체로 변환하는 팩토리 메서드
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // --- 임시 JSON 파싱 로직 (실제 백엔드 응답 구조에 맞게 수정 필요) ---
    // 실제 연결 시, 백엔드에서 파싱된 구조화된 데이터를 받아오도록 하는 것이 가장 좋습니다.
    return WeatherData(
      location: json['location'] ?? '위치 정보 없음',
      currentTemp: json['currentTemp'] ?? '?',
      weatherCondition: json['weatherCondition'] ?? '알 수 없음',
      fineDust: json['fineDust'] ?? '정보 없음',
      ultrafineDust: json['ultrafineDust'] ?? '정보 없음',
      uvIndex: json['uvIndex'] ?? '0',
    );
  }

  // 미세먼지 상태에 따른 색상 반환
  Color getDustColor(String value) {
    if (value.contains('좋음')) return Colors.blue.shade300;
    if (value.contains('보통')) return Colors.green.shade400;
    if (value.contains('나쁨')) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  // UV 지수 상태에 따른 색상 반환
  Color getUvColor(String value) {
    // uvIndex는 보통 숫자로만 구성되어야 합니다.
    String indexStr = value.split(' ')[0];
    int index = int.tryParse(indexStr) ?? 0;
    if (index <= 2) return Colors.green.shade400; // 낮음
    if (index <= 5) return Colors.yellow.shade600; // 보통
    if (index <= 7) return Colors.orange.shade400; // 높음
    return Colors.red.shade400; // 매우 높음
  }
}