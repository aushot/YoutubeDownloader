import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtubedownloader/homepage.dart';

void main() async{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: CupertinoThemeData(
        primaryColor: Color.fromARGB(100, 222, 8, 162),
        textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(),
        )
      ),
      home: HomePage(),
    );
  }
}
