import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  final dir = await getApplicationDocumentsDirectory();//initialising hive
  Hive.defaultDirectory = dir.path;// for hive
  final container = ProviderContainer();
  container.listen(authViewmodelProvider, (_, __) {}); // keep alive during startup
  final auth = container.read(authViewmodelProvider.notifier);
  await auth.initSharedPreferences();
  auth.loadCachedUser();          // instant: home screen shows right away

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));

  auth.getData().catchError((_) => null); // verify in background, never blocks
  // runApp(
  //   UncontrolledProviderScope(
  //     container: container,
  //     child: const MyApp(),
  //   ),
  // );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    return MaterialApp(

      title: 'Music App',
      home: currentUser==null?const SignupPage():const HomePage(),
      theme: AppTheme.darkThemeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}