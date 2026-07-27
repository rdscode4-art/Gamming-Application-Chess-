import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/services/storage_service.dart';
import 'core/di/service_locator.dart';
import 'routes/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/services/fcm_service.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'core/theme/theme_cubit.dart';
import 'features/profile/presentation/blocs/profile_bloc.dart';
import 'features/profile/presentation/blocs/profile_event.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

//just a commit

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  HttpOverrides.global = MyHttpOverrides();
  
  await StorageService.init();
  ApiClient.init();
  setupServiceLocator();

  String initialRoute = '/splash';

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FCMService().init();

    // Handle app launched from killed state via notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data['type'] == 'TOURNAMENT_MATCH_STARTED') {
      final gameId = initialMessage.data['gameId'];
      if (gameId != null) {
        initialRoute = '/tournament-vs/$gameId';
      }
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  if (initialRoute != '/splash') {
    // Only override the router's default initial location if opened via a specific notification
    appRouter.go(initialRoute);
  }

  runApp(const ChessPlatformApp());
}

class ChessPlatformApp extends StatelessWidget {
  const ChessPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<ProfileBloc>(create: (_) => getIt<ProfileBloc>()..add(LoadProfile())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Chess Platform',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
