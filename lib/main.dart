import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';
import 'package:my_task_planner/screens/eisenhower_matrix_screen.dart';
import 'package:my_task_planner/screens/home.dart';
import 'package:my_task_planner/screens/login_screen.dart';
import 'package:my_task_planner/screens/pomodoro_screen.dart';
import 'package:my_task_planner/screens/skill_details_screen.dart';
import 'package:my_task_planner/screens/skills_screen.dart';
import 'package:my_task_planner/screens/tasks_screen.dart';
import 'package:my_task_planner/screens/tutorial_sliders.dart';
import 'package:my_task_planner/services/auth_service.dart';
import 'package:my_task_planner/utils/shared_pref.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefUtil.init();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale(langEnCode, ""),
        Locale(langArCode, ""),
      ],
      path: "assets/languages",
      fallbackLocale: Locale(langEnCode),
      saveLocale: true,
      useOnlyLangCode: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthService(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _loggedIn = context.select((AuthService service) => service.isLoggedIn);
    return MaterialApp(
      title: 'My Task Planner',
      theme: ThemeData(
        fontFamily: "Chalkboard",
        primaryColor: colorPrimary,
        primaryColorLight: colorPrimaryLight,
        secondaryHeaderColor: colorAccent,
        appBarTheme: AppBarTheme.of(context).copyWith(color: colorPrimary),
      ),
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: Builder(builder: (context) {
        final firstOpen = SharedPrefUtil.isFirstOpen ?? true;

        if (firstOpen)
          return IntroScreen();
        else
          return _loggedIn ? HomeScreen() : LoginScreen();
        // return StreamBuilder(
        //   stream: _auth.authStateChanges,
        //   builder: (ctx, snapshot) {
        //     if (!snapshot.hasData) {
        //       return LoginScreen();
        //     }
        //     return HomeScreen();
        //   },
        // );
      }),
      routes: {
        TasksScreen.ROUTE_NAME: (ctx) => TasksScreen(),
        PomodoroScreen.ROUTE_NAME: (ctx) => PomodoroScreen(),
        EisenhowerMatrixScreen.ROUTE_NAME: (ctx) => EisenhowerMatrixScreen(),
        SkillsScreen.ROUTE_NAME: (ctx) => SkillsScreen(),
        SkillDetailsScreen.ROUTE_NAME: (ctx) => SkillDetailsScreen(),
      },
    );
  }
}
