void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '민간 구급차 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PrivateAmbulanceInfoScreen(),
    );
  }
}