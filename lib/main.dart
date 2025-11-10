import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/" : (context) => Main(),
      },
    );
  }
}

class Main extends StatefulWidget {
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  int currentPage = 0;
  dynamic pages = [
    Center(child: Text("Menu")),
    Center(child: Text("Location")),
    Center(child: Text("Home")),
    Center(child: Text("Community")),
    Center(child: Text("MyPage")),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Text("mOveOn")
            ]
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.notifications_on)),
            IconButton(onPressed: () {}, icon: Icon(Icons.login))
          ],

          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0), // 높이 설정
            child: Container(
              color: Colors.grey, // 선 색상
              height: 1.0,         // 선 두께
            ),
          ),

      ),
      body: IndexedStack(index: currentPage, children: pages),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (index) { setState(() {
            currentPage = index;
          });},

          backgroundColor: Colors.white, // 바탕색을 밝게
          selectedItemColor: Colors.blueAccent, // 선택된 아이템 색상
          unselectedItemColor: Colors.grey.shade700, // 선택되지 않은 아이템 색상
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.blueAccent,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
          type: BottomNavigationBarType.fixed,

          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: "전체메뉴"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_searching),
                label: "내위치"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "홈"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.question_answer),
                label: "커뮤니티"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "마이페이지"
            )
          ]
      )
    );
  }
}