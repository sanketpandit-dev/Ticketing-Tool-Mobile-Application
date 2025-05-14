import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickteting_tool/Controller/Login_Controller.dart';
import 'package:tickteting_tool/Controller/DepartmentController.dart';
import 'package:tickteting_tool/Controller/ResolvedTicketsCheckController.dart';
import 'package:tickteting_tool/Controller/TicketCountController.dart';
import 'package:tickteting_tool/Controller/TicketSubmissionController.dart';
import 'package:tickteting_tool/Controller/TicketTypeController.dart';
import 'package:tickteting_tool/Controller/TicketSubtypeController.dart';
import 'package:tickteting_tool/Controller/PriorityController.dart';
import 'package:tickteting_tool/Controller/TicketController.dart';
import 'package:tickteting_tool/Screens/Biomatric_Authentication/auth_provider.dart';
import 'package:tickteting_tool/Screens/Biomatric_Authentication/biometric_auth_screen.dart';
 import 'package:tickteting_tool/Screens/Splashscreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(),
        ),
        ChangeNotifierProvider<DepartmentController>(
          create: (_) => DepartmentController(),
        ),
        ChangeNotifierProvider<TicketTypeController>(
          create: (_) => TicketTypeController(),
        ),
        ChangeNotifierProvider<TicketSubtypeController>(
          create: (_) => TicketSubtypeController(),
        ),
        ChangeNotifierProvider<PriorityController>(
          create: (_) => PriorityController(),
        ),
        ChangeNotifierProvider<TicketController>(
          create: (_) => TicketController(),
        ),
        ChangeNotifierProvider(create: (context) => TicketSubmissionController()),

        ChangeNotifierProvider(create: (_) => Resolvedticketscheckcontroller()),
        ChangeNotifierProvider(create: (_) => TicketCountController()),
      ],
      child: MaterialApp(
        title: 'Ticketing Tool',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home:  BiometricAuthScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}