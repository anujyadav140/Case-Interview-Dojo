import 'package:bartleby/case_page.dart';
import 'package:bartleby/home.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Bartleby',
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorSchemes.darkZinc(),
        radius: 0.5,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => const HomePage());
        }
        if (settings.name != null && settings.name!.startsWith('/cases/')) {
          // final caseId = settings.name!.split('/').last; // We get caseId from arguments now
          final caseInterview = settings.arguments as CaseInterview;
          return MaterialPageRoute(
            builder: (context) => CaseInterviewPage(caseInterview: caseInterview),
            settings: settings, // Pass along the settings if needed for deep linking
          );
        }
        // Handle unknown routes, e.g., show a 404 page
        return MaterialPageRoute(builder: (context) => const Text('Page not found'));
      },
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
      ],
    );
  }
}

