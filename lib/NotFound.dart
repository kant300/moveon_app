
import 'package:flutter/material.dart';

class NotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text("404 - 페이지를 찾을 수 없습니다",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/'),
              child: Text("홈으로 이동"),
            ),
          ],
        ),
      ),
    );
  }
}