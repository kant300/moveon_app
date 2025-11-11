import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("생활",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(onPressed: () {}, icon: Icon(Icons.notifications_active, size: 26,)),
                      IconButton(onPressed: () {}, icon: Icon(Icons.settings, size: 26,))
                    ],
                  )
                ]
              ),
              SizedBox(height: 20),
              _buildButton(Icons.attach_money, "공과금 정산", () {
                Navigator.pushNamed(context, "/living/bill");
              }),
              _buildButton(Icons.person_pin_circle_rounded, "전입신고", () {
                Navigator.pushNamed(context, "/living/moveIn");
              }),
              _buildButton(Icons.restore_from_trash, "의류수거함 위치 정보", () {
                Navigator.pushNamed(context, "/living/clothingBin");
              }),
              _buildButton(Icons.recycling, "쓰레기 배출 정보", () {
                Navigator.pushNamed(context, "/living/trashInfo");
              }),
              _buildButton(Icons.energy_savings_leaf, "폐가전 수거 정보", () {
                Navigator.pushNamed(context, "/living/eco");
              }),
              _buildButton(Icons.local_police, "관공서 위치 정보", () {
                Navigator.pushNamed(context, "/living/government");
              }),
              _buildButton(Icons.local_hospital, "심야약국/병원 위치 정보", () {
                Navigator.pushNamed(context, "/living/night");
              }),
              SizedBox(height: 50),

              Text("안전",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildButton(Icons.crisis_alert, "성범죄자 위치 정보", () {
                Navigator.pushNamed(context, "/safety/sexOffender");
              }),
              _buildButton(Icons.emergency, "민간구급차 정보", () {
                Navigator.pushNamed(context, "/safety/ambulance");
              }),
              _buildButton(Icons.water_drop, "비상급수시설 위치 정보", () {
                Navigator.pushNamed(context, "/safety/water");
              }),
              _buildButton(Icons.night_shelter, "대피소 위치 정보", () {
                Navigator.pushNamed(context, "/safety/shelter");
              }),
              _buildButton(Icons.people, "공중화장실 위치 정보", () {
                Navigator.pushNamed(context, "/safety/restroom");
              }),
              _buildButton(Icons.video_camera_back, "CCTV 위치 정보", () {
                Navigator.pushNamed(context, "/safety/cctv");
              }),
              SizedBox(height: 50),

              Text("교통",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildButton(Icons.subway_outlined, "지하철 관련 정보", () {
                Navigator.pushNamed(context, "/transport/subway");
              }),
              _buildButton(Icons.directions_bus, "버스 관련 정보", () {
                Navigator.pushNamed(context, "/transport/busStation");
              }),
              _buildButton(Icons.ev_station, "전동휠체어 충전소 위치 정보", () {
                Navigator.pushNamed(context, "/transport/wheelchairCharger");
              }),
              _buildButton(Icons.local_parking, "공용주차장 위치 정보", () {
                Navigator.pushNamed(context, "/transport/localParking");
              }),
              SizedBox(height: 50),

              Text("커뮤니티",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildButton(Icons.handshake, "소분모임", () {
                Navigator.pushNamed(context, "/community/bulkBuy");
              }),
              _buildButton(Icons.event_note, "지역행사 정보", () {
                Navigator.pushNamed(context, "/community/localEvent");
              }),
              _buildButton(Icons.shopping_bag, "중고장터", () {
                Navigator.pushNamed(context, "/community/localStore");
              }),
              _buildButton(Icons.reviews, "동네후기 게시판", () {
                Navigator.pushNamed(context, "/community/localActivity");
              }),
              _buildButton(Icons.business_center, "구인/구직 게시판", () {
                Navigator.pushNamed(context, "/community/business");
              }),
              SizedBox(height: 50),

              Text("고객센터",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildButton(Icons.handshake, "자주 묻는 질문", () {
                Navigator.pushNamed(context, "/inquiry/faq");
              }),
              _buildButton(Icons.event_note, "고객문의", () {
                Navigator.pushNamed(context, "/inquiry/ask");
              }),
              _buildButton(Icons.shopping_bag, "공지사항", () {
                Navigator.pushNamed(context, "/inquiry/notice");
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 32),
          label: Text(label, style: TextStyle(fontSize: 20)),
          style: ElevatedButton.styleFrom(
            // foregroundColor: Color(0xFF1F7570), 색상 조정 (16진수 리터럴 : A, R, G, B)
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}