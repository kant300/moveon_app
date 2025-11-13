// import 'package:flutter/material.dart';
//
//
//
// class OnboardingScreen0 extends StatelessWidget{
//   @override
//   Widget build(BuildContext context) {
//     // 배경색 설정(민트/청록색 계열)
//     const Color primaryColor = Color(0xFF33C9C9);
//
//     return Scaffold(
//       body: Container(
//         color: primaryColor,  // 전체 배경색
//         child: Column(
//           children: <Widget>[
//             // 상단부분( mOveOn )
//             Expanded(child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const<Widget>[
//                   Text(
//                     'mOveOn',
//                     style: TextStyle(
//                       fontSize: 48,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 8,),
//                   Text(
//                     '새로운 시작, 안전한 정착',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                     ),
//                   )
//                 ],
//               ),
//             ) ,
//             ),
//             // 하단 버튼 부분
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: SizedBox(
//                 width: double.infinity, // 버튼 너비를 최대로
//                 height: 56, // 버튼 높이
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // 다음 화면(온보딩 1-1)으로 이동하는 로직 추가
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.yellow, // 노란색 버튼
//                     foregroundColor: Colors.black, // 텍스트 색상
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     '다음',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }