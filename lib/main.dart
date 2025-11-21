import 'package:flutter/material.dart';
import 'package:moveon_app/Checklist.dart';
import 'package:moveon_app/Home.dart';
import 'package:moveon_app/Menu.dart';
import 'package:moveon_app/MyPage.dart';
import 'package:moveon_app/NotFound.dart';
import 'package:moveon_app/living/TrashInfo.dart';
import 'package:moveon_app/member/Findid.dart';
import 'package:moveon_app/member/Findpwd.dart';
import 'package:moveon_app/Map.dart';
import 'package:moveon_app/member/Login.dart';
import 'package:moveon_app/Setting.dart';
import 'package:moveon_app/member/Profile.dart';
import 'package:moveon_app/member/Signup.dart';
import 'package:moveon_app/member/Updatepwd.dart';
import 'package:moveon_app/screens/onboarding/OnboardingAddress.dart';
import 'package:moveon_app/screens/onboarding/OnboardingCategory.dart';
import 'package:moveon_app/screens/onboarding/OnboardingComplete.dart';
import 'package:moveon_app/screens/onboarding/OnboardingStart.dart';
import 'package:moveon_app/safety/ambulance/Ambulance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // debug 배너 숨기기
      initialRoute: "/",
      routes: {
        "/onboarding" : (context) => OnboardingStart(),
        "/onboardingStart" : (context) => OnboardingStart(),
        "/onboardingAddress" : (context) => OnboardingAddress(),
        "/onboardingCategory" : (context) => OnboardingCategory(),
        "/onboardingComplete" : (context) => OnboardingComplete(),


        "/" : (context) => Main(),
        "/login" : (context) => Login() ,
        "/signup" : (context) => Signup() ,
        "/setting" : (context) => Setting() ,
        "/findid" : (context) => Findid() ,
        "/findpwd" : (context) => Findpwd() ,
        "/updatepwd" : (context) => Updatepwd() ,
        "/profile" : (context) => Profile() ,

        "/menu" : (context) => Menu(),

        "/safety/ambulance" : (context) => Ambulance(),
        "/map" : (context) => KakaoMap(),
        "/home" : (context) => Home(),
        "/mypage" : (context) => MyPage(),

        "/checklist" : (context) => Checklist(),
        "/checklistPersonal" : (context) => ChecklistPersonal(),

        "/living/trashInfo" : (context) => TrashInfo(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => NotFound()
      ),
    );
  }
}

class Main extends StatefulWidget {
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  int currentPage = 2;
  dynamic pages = [
    Menu(),
    KakaoMap(),
    Home(),
    Center(child: Text("Community")),
    MyPage()
  ];

  dynamic username;

  @override
  void initState() {
    super.initState();
    loadUserName();
  }
  void loadUserName() async {
    final mem = await SharedPreferences.getInstance();

    setState(() {
      username = null;
    });

    final loginToken = mem.getString('logintoken');
    final guestToken = mem.getString('guestToken');

    // 1) 게스트 username 제거
    if (guestToken != null && loginToken == null) {
      await mem.remove('mname');
      await mem.remove('logintoken');
      return;
    }

    // 2) 회원 토큰 있는 경우만 username 활성화
    if (loginToken != null) {
      setState(() {
        username = mem.getString('mname');
      });
    } else {
      setState(() {
        username = null;
      });
    }
  }

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
            IconButton(onPressed: () async{
              if(username == null){
              final result = await Navigator.pushNamed(context, "/login");
              if ( result != null && result is Map && result['mname'] != null) {
                setState(() {
                  username = result['mname'];
                });
              }
              } else {
                Navigator.pushNamed(context, "/setting");
              }
              }, icon: username == null ? Icon(Icons.login) : CircleAvatar( child: Text(username![0],
    ),)
    ),
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
                icon: Icon(Icons.my_location),
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