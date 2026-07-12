import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/game_data.dart';
import 'data/save_manager.dart';
import 'game/xinlu_game.dart';
import 'ui/menu_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (_) {}

  GameData.instance.init();
  try {
    await SaveManager.instance.init();
  } catch (_) {}

  try {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
      ],
      child: const XinluApp(),
    ),
  );
}

class GameState extends ChangeNotifier {
  bool _isInGame = false;
  bool get isInGame => _isInGame;

  void startGame() {
    _isInGame = true;
    notifyListeners();
  }

  void returnToMenu() {
    _isInGame = false;
    notifyListeners();
  }
}

class XinluApp extends StatelessWidget {
  const XinluApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '芯麓谷物语',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Consumer<GameState>(
        builder: (_, state, __) {
          if (state.isInGame) {
            return const XinluGameWrapper();
          }
          return const MainMenu();
        },
      ),
    );
  }
}

class XinluGameWrapper extends StatelessWidget {
  const XinluGameWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.read<GameState>().returnToMenu();
        }
      },
      child: const XinluGameWidget(),
    );
  }
}
