// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// final dio=Dio();
// class Menu extends StatefulWidget {
//   @override
//   MenuState createState() => MenuState();
// }
//
// // --- URL 실행 함수 정의 ---
// Future<void> _launchURL(String url) async {
//   final Uri uri = Uri.parse(url);
//
//   // URL을 실행할 수 있는지 확인 후 실행
//   if (await canLaunchUrl(uri)) {
//     await launchUrl(uri);
//   } else {
//     // URL을 열 수 없는 경우 오류 처리 (예: 사용자에게 메시지 표시)
//     throw 'Could not launch $url';
//   }
// }
//
//
//
// // MenuState 클래스: 위젯의 상태를 관리
// class MenuState extends State<Menu> {
//
//   String address = "주소 정보 없음";
//   List<String> wishposi = []; // 즐겨찾기 항목 리스트
//
//   String wishlist = ''; // 즐겨찾기 항목 문자열 (DB 통신용)
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // 위젯이 완전히 빌드된 후 1회만 호출하여 초기 데이터를 가져옵니다.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       tokencall();
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }
//
//   // 단일 메뉴 아이템(아이콘과 텍스트)을 구성하는 위젯
//   Widget _buildMenuItem(
//       IconData icon, // 표시할 아이콘
//       String label, // 아이콘 아래에 표시할 텍스트
//       VoidCallback onPressed, // 버튼 클릭 시 실행할 동작
//       Color iconColor,       // 아이콘의 색상
//       ) {
//     // ⭐️ isWished 상태를 확인하여 아이콘의 테두리나 배경을 다르게 처리할 수 있습니다.
//     final isWished = wishposi.contains(label);
//
//     return InkWell(// 아이콘을 원형으로 감싸는 버튼 (이미지의 스타일)
//       onTap: onPressed, // 클릭 이벤트 연결
//       child: Column(
//         children:[
//           Container(
//             padding:  EdgeInsets.all(10), // 아이콘 주변 여백
//             // 아이콘 배경 (이미지에는 배경색이 있으므로 색상 적용)
//             decoration: BoxDecoration(
//               // 아이콘별로 색상 다르게 설정 가능 (여기서는 기본 색상으로 통일)
//               color: Colors.white, // 배경색을 흰색으로 가정
//               borderRadius: BorderRadius.circular(10),
//               // 그림자 효과를 주어 입체감 표현
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   spreadRadius: 1,
//                   blurRadius: 3,
//                   offset:  Offset(0, 1), // 그림자 위치 (살짝 아래)
//                 ),
//               ],
//             ),
//             child: Icon(
//               icon,
//               size: 38, // 아이콘 크기 조정 (이미지 크기에 맞춰)
//               color: iconColor, // 아이콘 색상
//             ),
//           ),
//           SizedBox(height: 5), // 아이콘과 텍스트 사이 간격
//           // 메뉴 항목 레이블 텍스트
//           Text(
//             label,
//             textAlign: TextAlign.center, // 텍스트 중앙 정렬
//             style:  TextStyle(
//               fontSize: 12, // 텍스트 크기
//               color: Colors.black87, // 텍스트 색상
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 메뉴 아이템 목록을 Row로 구성하여 Grid 형태로 배치하는 함수
//   Widget _buildIconGrid(List<Widget> items, {int crossAxisCount = 4}) {
//     // 아이템을 `crossAxisCount` (한 줄에 표시할 개수)에 맞게 분할하여 `Row`로 구성
//     List<Widget> rows = [];
//     for (int i = 0; i < items.length; i += crossAxisCount) {
//       // 한 줄에 들어갈 아이템 리스트
//       List<Widget> rowItems = items.sublist(
//           i, i + crossAxisCount > items.length ? items.length : i + crossAxisCount);
//
//       // Row의 children을 Expanded로 감싸 동일한 너비를 할당합니다.
//       // ✨ 빈 Expanded를 추가하여 항상 4개의 공간을 확보합니다.
//       List<Widget> expandedRowItems = rowItems.map((item) => Expanded(child: item)).toList();
//
//       // 남은 공간을 채우기 위해 빈 Expanded를 추가하여 항상 4개의 열을 유지합니다.
//       while (expandedRowItems.length < crossAxisCount) {
//         expandedRowItems.add( Expanded(child: SizedBox.shrink()));
//       }
//
//       rows.add(
//         Padding(
//           padding:  EdgeInsets.only(bottom: 25.0), // 줄 간 간격
//           child: Row(
//             // 메인 축 정렬을 start로 하여 불필요한 중앙 정렬을 막습니다.
//             // 아이템들은 Expanded 덕분에 이미 균등한 공간을 차지합니다.
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: expandedRowItems,
//           ),
//         ),
//       );
//     }
//     // 완성된 Row들을 Column으로 묶어 반환
//     return Column(children: rows);
//   }
//
//   void tokencall() async{
//
//     setState(() {
//       address = "주소정보 없음";
//     });
//
//     final localsave = await SharedPreferences.getInstance();
//
//     final logintoken = localsave.getString("logintoken");
//     final guesttoken = localsave.getString("guestToken");
//
//     print(" logintoken = $logintoken");
//     print(" guestToken = $guesttoken");
//
//     String? token;
//
//     try {
//       if (guesttoken != null) {
//         print(" 게스트 토큰 감지");
//
//         final response = await dio.get(
//           "http://10.95.125.46:8080/api/guest/address",
//           options: Options(headers: {"Authorization": "Bearer $guesttoken"}),
//         );
//
//         final data = response.data;
//
//         print(" 게스트 주소 데이터: $data");
//
//         setState(() {
//           wishlist = data['wishlist'] ?? "";
//           wishposi = wishlist.split(",");
//           address = "${data['gaddress1']} ${data['gaddress2']} ${data['gaddress3']}";
//         });
//
//         return; //  회원 체크로 넘어가지 않도록 즉시 종료
//       }
//
//       // 2 회원 토큰 처리
//       if (logintoken != null) {
//         print(" 회원 토큰 감지");
//         final response = await dio.get(
//           "http://10.95.125.46:8080/api/member/info",
//           options: Options(headers: {"Authorization": "Bearer $logintoken"}),
//         );
//
//         final data = response.data;
//
//         print(" 회원 주소 데이터: $data");
//
//         setState(() {
//           address = "${data['maddress1']} ${data['maddress2']} ${data['maddress3']}";
//           wishlist = data['wishlist'] ?? "";
//           wishposi = wishlist.split(",");
//         });
//
//         return;
//       }
//
//       // 3️ 둘 다 없음
//       print(" 저장된 토큰 없음");
//
//     } catch (e) {
//       print(" 오류 발생: $e");
//     }
//   }
//
//   void togglewish(String category) async{
//     final localsave = await SharedPreferences.getInstance();
//     final logintoken = localsave.getString("logintoken");
//     final guesttoken = localsave.getString("guestToken");
//
//     String? token = logintoken ?? guesttoken;
//     if(token == null)  return; // 토큰 없으면 종료;
//
//     // 만약에 존재시 삭제
//     if(wishposi.contains(category)) {
//       wishposi.remove(category);
//     }else{
//       wishposi.add(category);
//     }
//     // 문자열로 변경
//     String Scategory = wishposi.join(",");
//
//     try{
//       final response = await dio.put("http://10.95.125.46:8080/api/guest/wishlist" ,
//         data: {"wishlist": Scategory},
//         options: Options(headers: {"Authorization" : "Bearer $token"},
//         ), );
//
//       print("즐겨찾기 확인 : ${response.data}");
//
//       setState(() {
//         wishlist = Scategory;
//       });
//     }catch(e) { print(e); }
//   }
//
//   Widget checkStart(
//       IconData icon,
//       String label,
//       VoidCallback on,
//       Color iconColor,
//       String categoryId,
//       )
//   {
//     bool starwish = wishposi.contains(categoryId); // 즐겨찾기 여부 확인
//
//     return InkWell(
//       onTap: on,
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               // 아이콘
//               Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 3,
//                       offset: Offset(0, 1),
//                     ),
//                   ],
//                 ),
//                 child: Icon(icon, size: 20, color: iconColor ),
//               ),
//               Positioned(right: 0, top: 0, child: InkWell(
//                 onTap: () {
//                   togglewish(categoryId);
//                 },
//                 child: Icon(
//                   starwish ? Icons.star : Icons.star_border,
//                   color: starwish ? Colors.amber : Colors.grey,
//                   size: 20,
//                 ),
//               ),
//               )
//             ],
//           ),
//           SizedBox(height: 3),
//           Text(label, style: TextStyle(fontSize: 12, color: Colors.black87),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // SafeArea: 노치/상태 표시줄 영역을 침범하지 않도록 함
//       body: SafeArea(
//         child: SingleChildScrollView( // 스크롤 가능하도록 설정
//           child: Padding(
//             padding: EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 최상단 상태바 (현재 위치, 즐겨찾기 아이콘 등)
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // 현재 위치 정보 (더미 텍스트)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("현재 위치",
//                             style: TextStyle(fontSize: 10, color: Colors.grey)),
//                         Text(
//                             address,
//                             style: TextStyle(
//                                 fontSize: 14, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     // 즐겨찾기 별 아이콘
//                     IconButton(
//                       // ⭐️ 이 버튼을 누르면 즐겨찾기 설정 화면으로 이동하도록 수정 가능
//                       onPressed: () {
//                         // Navigator.pushNamed(context, "/wishlist/settings");
//                       },
//                       icon:  Icon(
//                           Icons.star, color: Colors.amber, size: 28),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 25), // 섹션 시작 전 간격
//
//                 // 1. 생활 섹션
//                 Text(
//                     "생활",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
//                 ),
//                 SizedBox(height: 15),
//                 _buildIconGrid([
//                   // 생활 메뉴 아이템 목록 (이미지 순서 및 아이콘/텍스트 매칭)
//                   _buildMenuItem(Icons.attach_money, "공과금 정산", () =>
//                       Navigator.pushNamed(context, "/living/bill"), Colors.black),
//                   _buildMenuItem(Icons.person_pin_circle_rounded, "전입신고", () =>
//                       _launchURL("https://www.gov.kr/portal/onestopSvc/transferReport"),Colors.green),
//                   _buildMenuItem(Icons.checkroom, "의류수거함", () =>
//                       Navigator.pushNamed(
//                           context,
//                           "/map", // 지도 화면 라우트
//                           arguments: "clothingBin" // ⭐️ 카테고리 키 전달
//                       ),
//                       Colors.black
//                   ),
//                   // 의류수거함 아이콘 변경
//                   _buildMenuItem(Icons.recycling, "쓰레기 배출", () =>
//                       Navigator.pushNamed(context, "/living/trashInfo"), Colors.green),
//                   _buildMenuItem(Icons.energy_savings_leaf, "폐가전 수거", () =>
//                       _launchURL("https://15990903.or.kr/portal/main/main.do"), Colors.green),
//                   _buildMenuItem(Icons.local_police, "관공서", () =>
//                       Navigator.pushNamed(
//                           context,
//                           "/map",
//                           arguments: "government"
//                       ),
//                       Colors.black
//                   ),
//                   _buildMenuItem(Icons.local_hospital, "심야약국/병원", () =>
//                       Navigator.pushNamed(
//                           context,
//                           "/map",
//                           arguments: "night"
//                       ) ,
//                       Colors.red
//                   ),
//                 ], crossAxisCount: 4), // 한 줄에 4개 배치
//
//                 SizedBox(height: 20),
//
//                 // 2. 안전 섹션
//                 Text("안전",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
//                 ),
//                 SizedBox(height: 15),
//                 _buildIconGrid([
//                   // 안전 메뉴 아이템 목록
//                   _buildMenuItem(Icons.crisis_alert, "성범죄자", () =>
//                       Navigator.pushNamed(
//                           context,
//                           "/map",
//                           arguments: "sexCrime"
//                       ),
//                       Colors.red
//                   ),
//                   // 텍스트 축약
//                   _buildMenuItem(Icons.medical_information, "민간구급차", () =>
//                       Navigator.pushNamed(context, "/safety/ambulance"), Colors.black),
//                   // 텍스트 축약
//                   _buildMenuItem(Icons.water_drop, "비상급수시설", () =>
//                       Navigator.pushNamed(context, "/safety/water"), Colors.blue),
//                   // 텍스트 축약
//                   _buildMenuItem(Icons.night_shelter, "대피소", () =>
//                       Navigator.pushNamed(
//                           context,
//                           "/map",
//                           arguments: "shelter"
//                       ),
//                       Colors.red
//                   ),
//                   _buildMenuItem(Icons.wc, "공중화장실", () =>
//                       Navigator.pushNamed(
//                           context,
//                           "/map",
//                           arguments: "restroom"
//                       ),
//                       Colors.black
//                   ),
//                   _buildMenuItem(Icons.video_camera_back, "CCTV", () =>
//                       Navigator.pushNamed(
//                           context,
//                           "/map",
//                           arguments:"cctv"
//                       ),
//                       Colors.red
//                   ),
//                 ], crossAxisCount: 4),
//
//                 SizedBox(height: 20),
//
//                 // 3. 교통 섹션
//                 Text(
//                     "교통",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
//                 ),
//                 SizedBox(height: 15),
//                 _buildIconGrid([
//                   // 교통 메뉴 아이템 목록
//                   _buildMenuItem(Icons.subway_outlined, "지하철", () =>
//                       Navigator.pushNamed(
//                           context,
//                           "/map",
//                           arguments: "subway"
//                       ),
//                       Colors.blue
//                   ),
//                   _buildMenuItem(Icons.directions_bus, "버스정류장", () =>
//                       Navigator.pushNamed(context, "/transport/busStation") ,Colors.blue),
//                   _buildMenuItem(Icons.ev_station, "전동휠체어 충전소", () =>
//                       Navigator.pushNamed(
//                           context,
//                           "/map",
//                           arguments: "wheelchairCharger"
//                       ) ,
//                       Colors.green
//                   ),
//                   // 텍스트 축약
//                   _buildMenuItem(Icons.local_parking, "공용주차장", () =>
//                       Navigator.pushNamed(
//                           context,
//                           "/map",
//                           arguments: "localParking"
//                       ) ,
//                       Colors.black
//                   ),
//                   // 기존코드의 주유소는 이미지에 없으므로 제외
//                 ], crossAxisCount: 4),
//
//                 SizedBox(height: 20),
//
//                 // 4. 커뮤니티 섹션
//                 Text(
//                     "커뮤니티",
//                     style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
//                 ),
//                 SizedBox(height: 15),
//                 _buildIconGrid([
//                   // 커뮤니티 메뉴 아이템 목록
//                   _buildMenuItem(Icons.handshake, "소분모임", () =>
//                       Navigator.pushNamed(context, "/community/bulkBuy"),  Colors.deepOrange ),
//                   _buildMenuItem(Icons.event_note, "지역행사", () =>
//                       Navigator.pushNamed(context, "/community/localEvent"),Colors.black),
//                   _buildMenuItem(Icons.shopping_bag, "중고장터", () =>
//                       Navigator.pushNamed(context, "/community/localStore"), Colors.red ),
//                   _buildMenuItem(Icons.reviews, "동네후기", () =>
//                       Navigator.pushNamed(context, "/community/localActivity"), Colors.deepOrange),
//                   _buildMenuItem(Icons.business_center, "구인/구직", () =>
//                       Navigator.pushNamed(context, "/community/business") , Colors.black),
//                 ], crossAxisCount: 4),
//
//                 SizedBox(height: 20),
//
//                 // 5. 고객센터 섹션
//                 Text(
//                     "고객센터",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
//                 ),
//                 SizedBox(height: 15),
//                 _buildIconGrid([
//                   _buildMenuItem(Icons.quiz_outlined, "FAQ", () =>
//                       Navigator.pushNamed(context, "/inquiry/faq"), Colors.grey),
//                   // 아이콘 변경
//                   _buildMenuItem(Icons.headphones, "문의하기", () =>
//                       Navigator.pushNamed(context, "/inquiry/ask"), Colors.grey),
//                   // 아이콘 변경
//                   _buildMenuItem(Icons.campaign, "공지사항", () =>
//                       Navigator.pushNamed(context, "/inquiry/notice") ,Colors.grey),
//                   // 아이콘 변경
//                 ], crossAxisCount: 3),
//
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
// 메뉴다트