// import 'package:flutter/material.dart';
//
// class Ambulance extends StatelessWidget {
//   const Ambulance({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: const Center(child: Text('통합 지도'),)),
//         body: _buildFeeTable() );
//   }
//
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
//           const Text('> 왕복, 시외이유로 추가 비용을 요구하는 경우 -> 불법',
//               style: TextStyle(color: Colors.grey)),
//           const Text('> 의료장비 사용료, 처치비용, 의약품 사용 등의 추가 비용을 요구하는 경우 -> 불법',
//               style: TextStyle(color: Colors.grey)),
//           const Text('> 카드수수료, 보호자 합승비, 대기비 등의 추가 비용을 요구하는 경우 -> 불법',
//               style: TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }