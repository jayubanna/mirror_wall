import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror_wall/provider/home_provider.dart';
import 'package:mirror_wall/view/home_page.dart';
import 'package:provider/provider.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HomeProvider(),
        )
      ],
      builder: (context, child) {
        return Consumer<HomeProvider>(
          builder: (context, value, child) {
            return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: HomePage(),
            theme: value.Android_Theme_Mode
                ? ThemeData(brightness: Brightness.dark)
                : ThemeData(brightness: Brightness.light),
          );
          },
        );
      },
    );
  }
}
