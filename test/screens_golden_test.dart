// Renders the main screens with sample data to PNG files for visual review
// against design/screens. Regenerate with:
//   flutter test --update-goldens test/screens_golden_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:polycreds/api/api_client.dart';
import 'package:polycreds/api/models.dart';
import 'package:polycreds/l10n/l10n.dart';
import 'package:polycreds/screens/auth/code_screen.dart';
import 'package:polycreds/screens/auth/login_screen.dart';
import 'package:polycreds/screens/auth/pin_screens.dart';
import 'package:polycreds/screens/auth/server_screen.dart';
import 'package:polycreds/screens/home_shell.dart';
import 'package:polycreds/screens/notes/note_edit_screen.dart';
import 'package:polycreds/screens/notes/note_screen.dart';
import 'package:polycreds/screens/profile/language_screen.dart';
import 'package:polycreds/screens/profile/sessions_screen.dart';
import 'package:polycreds/screens/profile/settings_screen.dart';
import 'package:polycreds/screens/vault/credential_edit_screen.dart';
import 'package:polycreds/screens/vault/credential_screen.dart';
import 'package:polycreds/screens/vault/group_edit_screen.dart';
import 'package:polycreds/screens/vault/group_screen.dart';
import 'package:polycreds/state/session.dart';
import 'package:polycreds/state/settings.dart';
import 'package:polycreds/state/vault.dart';
import 'package:polycreds/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _noteJson =
    '{"ops":[{"insert":"Переписать историю"},{"insert":"\\n","attributes":{"header":2}},{"insert":"Склеить последние коммиты перед пушем в "},{"insert":"feature-ветку","attributes":{"bold":true}},{"insert":":\\ngit rebase -i HEAD~3"},{"insert":"\\n","attributes":{"code-block":"plain"}},{"insert":"git push --force-with-lease"},{"insert":"\\n","attributes":{"code-block":"plain"}},{"insert":"Уборка"},{"insert":"\\n","attributes":{"header":2}},{"insert":"Удалить ветки, которых нет на remote: "},{"insert":"git fetch -p","attributes":{"code":true}},{"insert":"\\n","attributes":{"list":"bullet"}},{"insert":"Никогда","attributes":{"italic":true}},{"insert":" не делать force-push в "},{"insert":"main","attributes":{"underline":true}},{"insert":".\\n","attributes":{"list":"bullet"}}]}';

const _server = 'https://vault.example.com';

class FakeApi extends ApiClient {
  FakeApi() : super(serverUrl: _server);

  @override
  Future<Credential> credential(int id) async => id == 7
      ? Credential(
          id: 7,
          groupId: 11,
          name: 'Prod · web-01',
          favorite: true,
          login: 'root',
          password: 'vX7#2qL!mRp9Tz',
          remote: const Remote(host: '10.0.0.12', port: 22, protocol: 'ssh'),
          note: 'Nginx + PHP 8.3. Деплой — только через CI, вручную не трогать.',
          createdAt: DateTime(2025, 3, 3),
          updatedAt: DateTime(2026, 9, 12),
        )
      : Credential(
          id: id,
          groupId: 10,
          name: 'GitHub',
          url: 'https://github.com/login',
          favorite: true,
          login: 'polyspirit',
          password: 'k7\$Qm2!vRx9#pL4&wZ8e',
          note: '{"ops":[{"insert":"Резервные коды 2FA — в заметке "},{"insert":"«GitHub recovery»","attributes":{"bold":true}},{"insert":".\\n"}]}',
          updatedAt: DateTime(2026, 9, 12),
        );

  @override
  Future<Note> note(int id) async => Note(
        id: id,
        groupId: 20,
        name: 'Git: полезные команды',
        note: _noteJson,
        updatedAt: DateTime(2026, 9, 18),
      );

  @override
  Future<List<DeviceToken>> tokens() async => [
        DeviceToken(id: 1, deviceName: 'iPhone · PolyCreds', isCurrent: true, lastUsedAt: DateTime.now(), ip: '185.12.64.7'),
        DeviceToken(
          id: 2,
          deviceName: 'Pixel 8 · PolyCreds',
          isCurrent: false,
          lastUsedAt: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime(2026, 5, 3),
          ip: '94.25.170.3',
        ),
        DeviceToken(
          id: 3,
          deviceName: 'iPad · PolyCreds',
          isCurrent: false,
          lastUsedAt: DateTime.now().subtract(const Duration(days: 21)),
          createdAt: DateTime(2026, 2, 14),
        ),
      ];

  @override
  Future<User> me() async => const User(id: 1, name: 'Polyspirit', email: 'poly@example.com');
}

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(File(f).readAsBytes().then((b) => ByteData.view(b.buffer)));
  }
  await loader.load();
}

late Session session;
late Vault vault;
late Settings settings;

Vault _sampleVault(ApiClient api) {
  final v = Vault(api)
    ..loaded = true
    ..rootGroupId = 1
    ..groups = const [
      Group(id: 10, name: 'Работа', type: GroupType.credential),
      Group(id: 11, name: 'Серверы', type: GroupType.credential),
      Group(id: 12, name: 'Личное', type: GroupType.credential),
      Group(id: 13, name: 'Финансы', type: GroupType.credential),
      Group(id: 20, name: 'Разработка', type: GroupType.note),
      Group(id: 21, name: 'Личное', type: GroupType.note),
    ];
  final now = DateTime(2026, 9, 20);
  v.credentials = [
    CredentialSummary(id: 1, groupId: 10, name: 'Confluence', url: 'company.atlassian.net', updatedAt: now, createdAt: DateTime(2025, 3, 3), login: 'poly@company.dev'),
    CredentialSummary(id: 2, groupId: 10, name: 'Figma', url: 'figma.com', updatedAt: now, createdAt: DateTime(2025, 3, 3), login: 'poly@example.com'),
    CredentialSummary(id: 3, groupId: 10, name: 'GitHub', url: 'https://github.com/login', favorite: true, updatedAt: now, createdAt: DateTime(2025, 3, 3), login: 'polyspirit'),
    CredentialSummary(id: 4, groupId: 10, name: 'GitLab', url: 'gitlab.company.dev', updatedAt: now, createdAt: DateTime(2025, 3, 3), login: 'poly@company.dev'),
    CredentialSummary(id: 5, groupId: 10, name: 'Jira', url: 'company.atlassian.net/jira', updatedAt: now, createdAt: DateTime(2025, 3, 3), login: 'poly@company.dev'),
    CredentialSummary(
        id: 7,
        groupId: 11,
        name: 'Prod · web-01',
        favorite: true,
        updatedAt: now, createdAt: DateTime(2025, 3, 3), login: 'root',
        remote: const Remote(host: '10.0.0.12', port: 22, protocol: 'ssh')),
    CredentialSummary(
        id: 8, groupId: 11, name: 'Stage · db', updatedAt: now, createdAt: DateTime(2025, 3, 3), login: 'deploy', remote: const Remote(host: '10.0.1.5', port: 22, protocol: 'ssh')),
    CredentialSummary(id: 9, groupId: 12, name: 'Госуслуги', url: 'gosuslugi.ru', updatedAt: now, createdAt: DateTime(2025, 3, 3), login: '+7 900 000-00-00'),
    CredentialSummary(id: 30, groupId: 1, name: 'Яндекс ID', url: 'passport.yandex.ru', updatedAt: now, createdAt: DateTime(2025, 3, 3), login: 'poly@yandex.ru'),
  ];
  v.notes = [
    NoteSummary(id: 1, groupId: 20, name: 'GitHub recovery', favorite: true, updatedAt: DateTime(2026, 9, 20)),
    NoteSummary(id: 2, groupId: 20, name: 'Git: полезные команды', updatedAt: DateTime(2026, 9, 18)),
    NoteSummary(id: 3, groupId: 21, name: 'Wi-Fi дома и на даче', favorite: true, updatedAt: DateTime(2026, 9, 2)),
    NoteSummary(id: 4, groupId: 1, name: 'Реквизиты ИП', updatedAt: DateTime(2026, 8, 14)),
  ];
  return v;
}

Widget _app(Widget home, {required bool dark, Locale locale = const Locale('ru')}) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider.value(value: vault),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(AppColors.light, Brightness.light),
        darkTheme: buildTheme(AppColors.dark, Brightness.dark),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        locale: locale,
        supportedLocales: L10n.supportedLocales,
        builder: (context, child) {
          setCurrentLocale(Localizations.localeOf(context));
          return child!;
        },
        localizationsDelegates: const [
          L10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        home: home,
      ),
    );

void main() {
  setUpAll(() async {
    final sdk = Platform.environment['FLUTTER_ROOT'] ?? '';
    await _loadFont('Onest', [
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) 'assets/fonts/Onest-$w.ttf',
    ]);
    await _loadFont('JetBrainsMono', [
      for (final w in ['Regular', 'Medium', 'SemiBold']) 'assets/fonts/JetBrainsMono-$w.ttf',
    ]);
    final lucide = Directory('${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev')
        .listSync()
        .firstWhere((d) => d.path.contains('lucide_icons_flutter'))
        .path;
    await _loadFont('packages/lucide_icons_flutter/Lucide', ['$lucide/assets/lucide.ttf']);
    await _loadFont('MaterialIcons', ['$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    await initializeDateFormatting();
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
        appName: 'PolyCreds', packageName: 'polycreds', version: '1.0.0', buildNumber: '1', buildSignature: '');
    settings = await Settings.load();
  });

  setUp(() {
    final api = FakeApi();
    session = Session(api: api, defaultServer: _server)
      ..user = const User(id: 1, name: 'Polyspirit', email: 'poly@example.com')
      ..pendingEmail = 'poly@example.com';
    vault = _sampleVault(api);
  });

  final screens = <String, Widget Function()>{
    'server': () => const ServerScreen(),
    'login': () => const LoginScreen(),
    'code': () => const CodeScreen(),
    'pin_create': () => const PinCreateScreen(),
    'pin_unlock': () => const PinUnlockScreen(),
    'main': () => const HomeShell(),
    'group': () => const GroupScreen(groupId: 10),
    'credential': () => const CredentialScreen(id: 3),
    'credential_remote': () => const CredentialScreen(id: 7),
    'credential_edit': () => const CredentialEditScreen(),
    'group_edit': () => const GroupEditScreen(group: Group(id: 10, name: 'Работа', type: GroupType.credential), type: GroupType.credential),
    'note': () => const NoteScreen(id: 2),
    'note_edit': () => NoteEditScreen(
        note: Note(id: 2, groupId: 20, name: 'Git: полезные команды', note: _noteJson, updatedAt: DateTime(2026, 9, 18))),
    'settings': () => const SettingsScreen(),
    'sessions': () => const SessionsScreen(),
    'language': () => const LanguageScreen(),
  };

  for (final dark in [false, true]) {
    for (final e in screens.entries) {
      testWidgets('${e.key} ${dark ? 'dark' : 'light'}', (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3;
        tester.view.padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
        tester.view.viewPadding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
        addTearDown(tester.view.reset);

        await tester.runAsync(() async {
          await tester.pumpWidget(_app(e.value(), dark: dark));
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/${e.key}_${dark ? 'dark' : 'light'}.png'));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    }
  }

  for (final name in ['main', 'credential_remote', 'credential_edit', 'settings', 'sessions', 'pin_create']) {
    testWidgets('$name english', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
      tester.view.viewPadding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
      addTearDown(tester.view.reset);
      addTearDown(() => setCurrentLocale(const Locale('ru')));

      await tester.runAsync(() async {
        await tester.pumpWidget(_app(screens[name]!(), dark: false, locale: const Locale('en')));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/en/${name}_light.png'));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  }

  testWidgets('empty vault', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    vault
      ..credentials = []
      ..groups = [];
    await tester.pumpWidget(_app(const HomeShell(), dark: false));
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/empty_light.png'));
  });
}
