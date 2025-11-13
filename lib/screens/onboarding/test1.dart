// // onboarding/onboarding_intro.dart
//
// import 'package:flutter/material.dart';
// import 'onboarding_address.dart'; // 다음 페이지 import
//
// class OnboardingIntroScreen extends StatelessWidget {
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
//
//             // "다음" 버튼 (다음 페이지로 이동)
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Align(
//                 alignment: Alignment.center,
//                 child: SizedBox(
//                   width: 300, // 직접 지정
//                   height: 56,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: primaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => OnboardingScreen0()),
//                       );
//                     },
//                     child: const Text('다음', style: TextStyle(fontSize: 18)),
//                   ),
//                 ),
//               ),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }