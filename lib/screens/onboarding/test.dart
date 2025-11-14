// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'onboarding_complete.dart'; // 다음 페이지 import
//
// // 주소 또는 현재 위치를 입력받는 온보딩 페이지
// class OnboardingAddress extends StatefulWidget {
//
//
//   @override
//   State<OnboardingAddress> createState() => OnboardingAddressState();
// }
//
// class OnboardingAddressState extends State<OnboardingAddress> {
//   // 사용자가 입력한 주소를 저장할 컨트롤러
//   final TextEditingController addressController = TextEditingController();
//
//   // 현재위치 문자열로 저장 (위도, 경도)
//   String? currentLocation;
//
//   // 📍 현재 위치를 가져오는 메서드
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // 1️⃣ 위치 서비스가 켜져 있는지 확인
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // 꺼져 있으면 안내 메시지 표시
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('위치 서비스를 활성화해주세요.')),
//       );
//       return;
//     }
//
//     // 2️⃣ 권한 상태 확인 및 요청
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // 사용자가 권한 거부한 경우
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('위치 권한이 필요합니다.')),
//         );
//         return;
//       }
//     }
//
//     // 3️⃣ 영구적으로 권한이 거부된 경우 처리
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('위치 접근 권한이 영구적으로 거부되었습니다.\n설정에서 변경해주세요.'),
//         ),
//       );
//       return;
//     }
//
//     // 4️⃣ 위치 정보 가져오기 (현재 위도, 경도)
//     final position = await Geolocator.getCurrentPosition();
//
//     // 5️⃣ 상태 업데이트 (화면에 표시)
//     setState(() {
//       _currentLocation = "(${position.latitude}, ${position.longitude})";
//       _addressController.text = _currentLocation!; // 입력창에 자동 표시
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("위치 선택")),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 🏠 주소 입력 필드
//             TextField(
//               controller: _addressController,
//               decoration: const InputDecoration(
//                 labelText: "주소를 직접 입력하거나 현재위치를 선택하세요",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // 📍 현재 위치 가져오기 버튼
//             ElevatedButton.icon(
//               icon: const Icon(Icons.my_location),
//               label: const Text("현재위치로 찾기"),
//               onPressed: _getCurrentLocation,
//             ),
//             const SizedBox(height: 40),
//
//             // 다음 버튼 — 주소나 위치가 비어있으면 안내 메시지 출력
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//                 minimumSize: const Size(200, 50),
//               ),
//               onPressed: () {
//                 final address = _addressController.text.trim();
//
//                 if (address.isEmpty) {
//                   // 입력값이 없으면 스낵바로 알림
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("주소 또는 위치를 입력해주세요.")),
//                   );
//                   return;
//                 }
//
//                 // 주소값을 다음 페이지(OnboardingComplete)에 전달하며 이동
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => OnboardingComplete(address: address),
//                   ),
//                 );
//               },
//               child: const Text("다음", style: TextStyle(color: Colors.white, fontSize: 18)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


