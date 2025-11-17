// lib/member/Profile.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio=Dio();

class Profile extends StatefulWidget {
  StateProfile createState() => StateProfile();
}

class StateProfile extends State<Profile> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfo();
  }
  dynamic memberdate = {};
  void getinfo() async{ // 정보 호출
      final localsave = await SharedPreferences.getInstance();
      final token = await localsave.getString("logintoken");
      try{
      final response = await dio.get("http://10.164.103.46:8080/api/member/info",
      options: Options(headers: { "Authorization" : "Bearer $token"},),
      );
      final data = await response.data;
      print(data);
      setState(() {
        memberdate=data;
        mnameCont.text = data['mname'];
        mphoneCont.text = data['mphone'];
        memailCont.text = data['memail'];
        addressCont.text = "${data['maddress1']} ${data['maddress2']} ${data['maddress3']}";
      });
    }catch(e) {print(e); }
  }

  TextEditingController mnameCont = TextEditingController();
  TextEditingController mphoneCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController memailCont = TextEditingController();


  // KaKao api
  Future<String> getKakaomap(double lon , double lat) async{
    dynamic addressKey = "0b209f5c7458468469df5492074343bf"; // api kakao rest key
    // KaKao 좌표로 주소 변환 Rest Key
    final response = await dio.get("https://dapi.kakao.com/v2/local/geo/coord2address.json" ,
    queryParameters: {
      "x" : lon.toString(),
      "y" : lat.toString(),
    },
      options: Options(headers: {"Authorization" : "KakaoAK $addressKey"},
      ),
    );
    final doc = response.data['documents'] as List;
    if(doc.isEmpty) return "불가";
    final add = doc[0]["address"] as Map<String , dynamic> ;
    return "${add['region_1depth_name']} " // 시
           "${add['region_2depth_name']} " // 구
           "${add['region_3depth_name']} " // 동
           "${add['main_address_no']}" ; // 상세 주소
  } // get kakao map end

  // 내위치
  Future<bool> addressprint() async{
    bool EnableStart = await Geolocator.isLocationServiceEnabled(); // 스마트폰 gps 기능 확인 여부
    if(!EnableStart) {
      print("GPS 기능 안켜져있음");
      return Future.value(false); // 안켜져있으면 실패
    };
    // 권한 여부 확인
    LocationPermission locationPermission = await Geolocator.checkPermission();

      if(locationPermission == LocationPermission.denied) {
        // 권한 요청 확인후 맞으면 팝업창 띄워줌 [ 허용 / 거부 ]
        locationPermission = await Geolocator.requestPermission();
        // 거부 누르면 false 로 반환
        if (locationPermission == LocationPermission.denied) {
          return Future.value(false);
        }
      } // 강력 팝업 : 거부 여러번 실행시 발동 { 다시는 묻지않기 }
      if(locationPermission == LocationPermission.deniedForever){
        return Future.value(false);
      }
      Position position = await Geolocator.getCurrentPosition();
      dynamic x = position.longitude; // 경도
      dynamic y = position.latitude; // 위도

      String address = await getKakaomap(x, y);

      setState(() {
        addressCont.text = address;
      });

      // 허용시 true
      return Future.value(true);
  }
  
  void profileupdate() async{
    try{
      final address = addressCont.text.split(" ");
      final obj = {
        "mid" : memberdate['mid'] ,
        "mname" : mnameCont.text,
        "mphone" : mphoneCont.text,
        "memail" : memailCont.text,
        "maddress1" : address[0],
        "maddress2" : address[1],
        "maddress3" : address[2] + " " +address[3],
      };
      final response = await dio.put("http://10.164.103.46:8080/api/member/update" , data: obj);
      final data = await response.data;
      print(data);

      showDialog(context: context, builder: (context) {
        return AlertDialog(
          content: Text("프로필 수정 완료"),
          actions: [
            TextButton(onPressed: () { Navigator.pushReplacementNamed(context , "/setting"); },
            child: Text("확인"),
            ),
          ],
        );
      });
    }catch(e) { print(e); }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar( title: Text("프로필 수정"),),
      body: Column( children: [
        TextField(controller: mnameCont ,),
        TextField(controller: mphoneCont , ),
        TextField(controller: memailCont , ),
        TextField(controller: addressCont , ),
        OutlinedButton(onPressed: addressprint , child: Text("내위치 조회"),),
        TextButton(onPressed: profileupdate , child: Text("변경"),),
      ],),
    );
  }
}