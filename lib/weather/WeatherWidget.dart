import 'package:flutter/material.dart';
// Service와 Model Import
import 'package:moveon_app/weather/WeatherService.dart';
import 'package:moveon_app/weather/WeatherModel.dart';
// 위치 정보를 위해 'geolocator' 패키지가 필요합니다.
// import 'package:geolocator/geolocator.dart';


// 2. 메인 함수 (앱 테스트를 위해 포함)
void main() {
  runApp(const WeatherApp());
}

// 3. 앱 위젯
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '현재 위치 날씨 위젯',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Home.dart 파일에서 이 위젯을 가져가 사용하면 됩니다.
      home: const WeatherScreen(),
    );
  }
}

// 4. 메인 화면 위젯 (상태 관리 및 서비스 호출)
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService(); // 서비스 인스턴스
  WeatherData? _weatherData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  // 위치 기반으로 백엔드 API를 호출하는 로직
  Future<void> _fetchWeatherData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // 1. 위치 정보 획득 (geolocator 패키지 필요)
    double lat = 37.498175; // 임시 위도 (강남역)
    double lon = 127.027618; // 임시 경도 (강남역)

    /* // 실제 geolocator 사용 예시 (패키지 설치 후 주석 해제)
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      // ... (위치 권한 요청 및 위치 획득 로직)
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "위치 정보를 가져오는 데 실패했습니다: ${e.toString()}";
          _isLoading = false;
        });
      }
      return;
    }
    */

    // 2. 서비스 로직 호출
    try {
      final data = await _weatherService.fetchWeatherData(lat, lon);

      if (mounted) {
        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('현재 위치 날씨 위젯'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade300,
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchWeatherData,
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.lightBlue)
              : _errorMessage.isNotEmpty
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _fetchWeatherData,
                icon: const Icon(Icons.replay),
                label: const Text('다시 시도'),
              )
            ],
          )
              : _weatherData != null
              ? WeatherCard(data: _weatherData!) // 날씨 위젯 표시
              : const Text('날씨 데이터를 불러오지 못했습니다.', style: TextStyle(color: Colors.red)),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}

// 5. 날씨 위젯 (클릭 가능한 카드)
class WeatherCard extends StatelessWidget {
  final WeatherData data;

  const WeatherCard({super.key, required this.data});

  // 상세 화면으로 이동하는 함수
  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherDetailScreen(data: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context), // 클릭 시 상세 화면으로 이동
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          // 배경 그라데이션을 사용하여 시각적 효과를 높임
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade300,
              Colors.lightBlue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 위치 및 날씨 정보
            Text(
              data.location,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.currentTemp,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      data.weatherCondition,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                // 날씨 아이콘 (예시: 맑음)
                Icon(
                  Icons.wb_sunny_rounded,
                  size: 60,
                  color: Colors.yellow.shade200,
                ),
              ],
            ),
            const Divider(color: Colors.white54, height: 30),

            // 2. 미세먼지, 초미세먼지, 자외선차단치수 위젯 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAirQualityTile(
                  context,
                  title: '미세먼지',
                  // 괄호 안의 상태(예: 보통)만 추출
                  value: data.fineDust.contains('(') ? data.fineDust.split('(')[1].replaceAll(')', '') : data.fineDust,
                  color: data.getDustColor(data.fineDust),
                ),
                _buildAirQualityTile(
                  context,
                  title: '초미세먼지',
                  // 괄호 안의 상태(예: 좋음)만 추출
                  value: data.ultrafineDust.contains('(') ? data.ultrafineDust.split('(')[1].replaceAll(')', '') : data.ultrafineDust,
                  color: data.getDustColor(data.ultrafineDust),
                ),
                _buildAirQualityTile(
                  context,
                  title: 'UV 지수',
                  value: data.uvIndex.contains('/') ? data.uvIndex : '${data.uvIndex} / 8',
                  color: data.getUvColor(data.uvIndex),
                ),
              ],
            ),

            const SizedBox(height: 10),
            // 클릭 유도 텍스트
            const Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '상세 정보 보기',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 미세먼지/UV 정보를 표시하는 작은 타일 위젯
  Widget _buildAirQualityTile(BuildContext context, {required String title, required String value, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// 6. 상세 화면 위젯
class WeatherDetailScreen extends StatelessWidget {
  final WeatherData data;

  const WeatherDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${data.location} 상세 날씨'),
        backgroundColor: Colors.lightBlue.shade300,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 큰 제목
            Center(
              child: Text(
                data.currentTemp,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w200,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            Center(
              child: Text(
                data.weatherCondition,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 상세 정보 섹션 (미세먼지, 초미세먼지, UV 지수)
            _buildDetailSection(
              title: '미세먼지 정보 (PM10)',
              value: data.fineDust,
              icon: Icons.filter_drama_outlined,
              color: data.getDustColor(data.fineDust),
            ),
            _buildDetailSection(
              title: '초미세먼지 정보 (PM2.5)',
              value: data.ultrafineDust,
              icon: Icons.cloud_outlined,
              color: data.getDustColor(data.ultrafineDust),
            ),
            _buildDetailSection(
              title: '자외선 지수 (UV Index)',
              value: '${data.uvIndex} - 자외선 차단 필요 수준',
              icon: Icons.wb_sunny_outlined,
              color: data.getUvColor(data.uvIndex),
            ),

            const SizedBox(height: 40),
            const Center(
              child: Text(
                '이곳은 상세 예보 및 시간대별 예보를 표시하는 공간입니다.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상세 화면용 항목 위젯
  Widget _buildDetailSection({required String title, required String value, required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // 항목 상태에 따른 왼쪽 테두리 색상 강조
          border: Border(left: BorderSide(color: color, width: 5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}