import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/session.dart';
import 'state/settings.dart';
import 'state/vault.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final settings = await Settings.load();
  final session = Session();
  final vault = Vault(session.api);
  session.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: session),
      ChangeNotifierProvider.value(value: vault),
    ],
    child: const PolyCredsApp(),
  ));
}
