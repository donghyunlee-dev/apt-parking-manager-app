import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/sessions/app_inializer.dart';
import 'core/sessions/session_storage.dart';
import 'core/devices/device_id_provider.dart';
import 'core/sessions/app_init_result.dart';
import 'core/sessions/session_context.dart';
import 'screen/login/login_screen.dart';
import 'screen/home/home_screen.dart';
import 'screen/resident/resident_vehicle_register_screen.dart';
import 'screen/camera/vehicle_scan_screen.dart';
import 'screen/app_init_screen.dart';
import 'screen/login/services/fin_api.dart';
import 'screen/login/services/login_service.dart';
import 'screen/visitor/visitor_vehicle_register_screen.dart';
import 'screen/search/search_vehicle_screen.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final secureStorage = const FlutterSecureStorage();

  final sessionStorage = SessionStorage(secureStorage);
  final deviceIdProvider = DeviceIdProvider(secureStorage);
  final sessionContext = SessionContext();
  final finApi = FinApi();
  
  final initializer = AppInitializer(
    sessionStorage: sessionStorage,
    deviceIdProvider: deviceIdProvider,
  );

  final loginService = LoginService(
    sessionStorage: sessionStorage,
    sessionContext: sessionContext,
    finApi: finApi,
  );
  
  final result = await initializer.initialize();

  if (result is AppInitReady) {
    sessionContext.setSession(result.session);
    debugPrint('🚀 AppInit Session loaded: ${result.session}');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<LoginService>.value(value: loginService),
        ChangeNotifierProvider<SessionContext>.value(value: sessionContext),
      ],
      child: ParkingApp(result: result,),
    ),
  );
}

class ParkingApp extends StatelessWidget {
  final AppInitResult result;
  
  ParkingApp({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AppInitScreen(result: result),
        '/home': (context) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/vehicle-scan': (_) => const VehicleScanScreen(),
        '/resident/vehicle/register': (context) => const ResidentVehicleRegisterScreen(),
        '/visitor/vehicle/register': (context) => const VisitorVehicleRegisterScreen(),
        '/vehicle/search': (context) => const SearchVehicleScreen(),
      },
    );
  }
}
 
