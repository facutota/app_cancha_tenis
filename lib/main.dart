import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'app/data/model/agendamientos.dart';
import 'app/ui/pages/home_screen.dart';
import 'app/values/theme_app.dart';

Future main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeApp themeApp = ThemeApp();
    AgendamientosModel miAgendamientosModel = AgendamientosModel();
    return ChangeNotifierProvider(
      create: (context) =>
          AgendamientosModel(), // Crear una instancia de AgendamientosModel
      child: GetMaterialApp(
        title: 'Court Reserve App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: themeApp.textTheme,
        ),
        home: HomeScreen(agendamientosModel: miAgendamientosModel),
      ),
    );
  }
}
