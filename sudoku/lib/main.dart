import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

import 'alerts/all.dart';
import 'board_style.dart';
import 'constants.dart';
import 'dialog_helper.dart';
import 'splash_screen_page.dart';
import 'styles.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_TITLE,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Styles.primaryColor,
      ),
      home: const SplashScreenPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool firstRun = true;
  bool gameOver = false;
  int timesCalled = 0;
  bool isButtonDisabled = false;
  bool isFABDisabled = false;
  late List<List<List<int>>> gameList;
  late List<List<int>> game;
  late List<List<int>> gameCopy;
  late List<List<int>> gameSolved;
  static String? currentDifficultyLevel;
  static String? currentTheme;
  static String? currentAccentColor;
  static String platform = () {
    if (kIsWeb) {
      return 'web-${defaultTargetPlatform.toString().replaceFirst("TargetPlatform.", "").toLowerCase()}';
    } else {
      return defaultTargetPlatform
          .toString()
          .replaceFirst("TargetPlatform.", "")
          .toLowerCase();
    }
  }();
  static bool isDesktop = [PLATFORM_WINDOWS, PLATFORM_LINUX, PLATFORM_MACOS]
      .contains(platform);

  @override
  void initState() {
    super.initState();
    try {
      doWhenWindowReady(() {
        appWindow.alignment = Alignment.center;
        appWindow.minSize = const Size(WINDOW_MIN_SIZE, WINDOW_MIN_SIZE);
      });
    } on UnimplementedError catch (e) {
      debugPrint('Window ready not supported on this platform: $e');
    }
    getPrefs().whenComplete(() {
      if (currentDifficultyLevel == null) {
        currentDifficultyLevel = DEFAULT_DIFFICULTY;
        setPrefs(PREF_DIFFICULTY_LEVEL);
      }
      if (currentTheme == null) {
        if (MediaQuery.maybeOf(context)?.platformBrightness != null) {
          currentTheme =
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? THEME_LIGHT
                  : THEME_DARK;
        } else {
          currentTheme = DEFAULT_THEME;
        }
        setPrefs(PREF_THEME);
      }
      if (currentAccentColor == null) {
        currentAccentColor = DEFAULT_ACCENT_COLOR;
        setPrefs(PREF_ACCENT_COLOR);
      }
      newGame(currentDifficultyLevel!);
      changeTheme('set');
      changeAccentColor(currentAccentColor!, true);
    });
  }

  Future<void> getPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        currentDifficultyLevel = prefs.getString(PREF_DIFFICULTY_LEVEL);
        currentTheme = prefs.getString(PREF_THEME);
        currentAccentColor = prefs.getString(PREF_ACCENT_COLOR);
      });
    } catch (e) {
      debugPrint('Error reading preferences: $e');
    }
  }

  Future<void> setPrefs(String property) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (property == PREF_DIFFICULTY_LEVEL && currentDifficultyLevel != null) {
        await prefs.setString(PREF_DIFFICULTY_LEVEL, currentDifficultyLevel!);
      } else if (property == PREF_THEME && currentTheme != null) {
        await prefs.setString(PREF_THEME, currentTheme!);
      } else if (property == PREF_ACCENT_COLOR && currentAccentColor != null) {
        await prefs.setString(PREF_ACCENT_COLOR, currentAccentColor!);
      }
    } catch (e) {
      debugPrint('Error saving preference: $e');
    }
  }

  void changeTheme(String mode) {
    setState(() {
      final isLightTheme = currentTheme == THEME_LIGHT;
      final shouldSwitch = mode == 'switch';

      if (shouldSwitch) {
        currentTheme = isLightTheme ? THEME_DARK : THEME_LIGHT;
      }

      if (currentTheme == THEME_LIGHT) {
        Styles.primaryBackgroundColor = Styles.white;
        Styles.secondaryBackgroundColor = Styles.white;
        Styles.foregroundColor = Styles.darkGrey;
      } else {
        Styles.primaryBackgroundColor = Styles.darkGrey;
        Styles.secondaryBackgroundColor = Styles.grey;
        Styles.foregroundColor = Styles.white;
      }
      setPrefs(PREF_THEME);
    });
  }

  void changeAccentColor(String color, [bool firstRun = false]) {
    setState(() {
      if (Styles.accentColors.keys.contains(color)) {
        Styles.primaryColor = Styles.accentColors[color]!;
      } else {
        currentAccentColor = 'Blue';
        Styles.primaryColor = Styles.accentColors[color]!;
      }
      if (color == 'Red') {
        Styles.secondaryColor = Styles.orange;
      } else {
        Styles.secondaryColor = Styles.lightRed;
      }
      if (!firstRun) {
        setPrefs('currentAccentColor');
      }
    });
  }

  void checkResult() {
    try {
      if (SudokuUtilities.isSolved(game)) {
        isButtonDisabled = !isButtonDisabled;
        gameOver = true;
        Timer(ANIMATION_DURATION_CHECK_RESULT, () {
          showAnimatedDialog<void>(
              context: context,
              barrierDismissible: true,
              duration: ANIMATION_DURATION_LONG,
              builder: (_) => const AlertGameOver()).whenComplete(() {
            if (AlertGameOver.newGame) {
              newGame();
              AlertGameOver.newGame = false;
            } else if (AlertGameOver.restartGame) {
              restartGame();
              AlertGameOver.restartGame = false;
            }
          });
        });
      }
    } on InvalidSudokuConfigurationException {
      return;
    }
  }

  static Future<List<List<List<int>>>> getNewGame(
      [String difficulty = DEFAULT_DIFFICULTY]) async {
    int emptySquares;
    switch (difficulty) {
      case 'test':
        emptySquares = TEST_EMPTY_SQUARES;
        break;
      case 'beginner':
        emptySquares = BEGINNER_EMPTY_SQUARES;
        break;
      case 'easy':
        emptySquares = EASY_EMPTY_SQUARES;
        break;
      case 'medium':
        emptySquares = MEDIUM_EMPTY_SQUARES;
        break;
      case 'hard':
        emptySquares = HARD_EMPTY_SQUARES;
        break;
      case 'expert':
        emptySquares = EXPERT_EMPTY_SQUARES;
        break;
      default:
        emptySquares = TEST_EMPTY_SQUARES;
        break;
    }
    
    // Retry with fewer empty squares if puzzle generation fails
    int maxRetries = 3;
    int retryCount = 0;
    int currentEmpty = emptySquares;
    
    while (retryCount < maxRetries) {
      try {
        SudokuGenerator generator = SudokuGenerator(emptySquares: currentEmpty);
        return [generator.newSudoku, generator.newSudokuSolved];
      } catch (e) {
        debugPrint('Failed to generate puzzle with $currentEmpty empty squares: $e');
        retryCount++;
        currentEmpty = (currentEmpty - 2).clamp(MIN_EMPTY_SQUARES, emptySquares);
        if (retryCount >= maxRetries) {
          debugPrint('Could not generate valid puzzle after $maxRetries retries');
          rethrow;
        }
      }
    }
    
    throw Exception('Failed to generate valid Sudoku puzzle');
  }

  static List<List<int>> copyGrid(List<List<int>> grid) {
    return grid.map((row) => [...row]).toList();
  }

  Future<void> setGame(int mode, [String difficulty = 'easy']) async {
    if (mode == 1) {
      // Use List.generate to create independent rows - List.filled creates shallow copies
      game = List<List<int>>.generate(
          9, (_) => List<int>.filled(9, 0));
      gameCopy = List<List<int>>.generate(
          9, (_) => List<int>.filled(9, 0));
      gameSolved = List<List<int>>.generate(
          9, (_) => List<int>.filled(9, 0));
    } else {
      gameList = await getNewGame(difficulty);
      game = gameList[0];
      gameCopy = copyGrid(game);
      gameSolved = gameList[1];
    }
  }

  void showSolution() {
    setState(() {
      game = copyGrid(gameSolved);
      isButtonDisabled =
          !isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
      gameOver = true;
    });
  }

  void newGame([String difficulty = 'easy']) {
    setState(() {
      isFABDisabled = !isFABDisabled;
    });
    Future.delayed(const Duration(milliseconds: 200), () async {
      await setGame(2, difficulty);
      setState(() {
        isButtonDisabled =
            isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
        gameOver = false;
        isFABDisabled = !isFABDisabled;
      });
    });
  }

  void restartGame() {
    setState(() {
      game = copyGrid(gameCopy);
      isButtonDisabled =
          isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
      gameOver = false;
    });
  }

  List<Widget> createButtons() {
    if (firstRun) {
      setGame(1);
      firstRun = false;
    }

    List<Widget> buttonList = List<Widget>.filled(9, const SizedBox());
    for (var i = 0; i <= 8; i++) {
      var k = timesCalled;
      buttonList[i] = Padding(
        padding: const EdgeInsets.all(0.6),
        child: SizedBox(
          key: Key('grid-button-$k-$i'),
          width: buttonSize(),
          height: buttonSize(),
          child: TextButton(
            onPressed: isButtonDisabled || gameCopy[k][i] != 0
                ? null
                : () {
                    showAnimatedDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        duration: ANIMATION_DURATION_MEDIUM,
                        builder: (_) => const AlertNumbersState())
                        .whenComplete(() {
                      callback([k, i], AlertNumbersState.number);
                      AlertNumbersState.number = null;
                    });
                  },
            onLongPress: isButtonDisabled || gameCopy[k][i] != 0
                ? null
                : () => callback([k, i], 0),
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all<Color>(buttonColor(k, i)),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) {
                  return gameCopy[k][i] == 0
                      ? emptyColor(gameOver)
                      : Styles.foregroundColor;
                }
                return game[k][i] == 0
                    ? buttonColor(k, i)
                    : Styles.secondaryColor;
              }),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                borderRadius: buttonEdgeRadius(k, i),
              )),
              side: WidgetStateProperty.all<BorderSide>(getGridBorder(k, i)),
              elevation: WidgetStateProperty.resolveWith<double>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return 2.0;
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return 4.0;
                  }
                  return 1.0;
                },
              ),
              shadowColor: WidgetStateProperty.all<Color>(
                  Styles.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              game[k][i] != 0 ? game[k][i].toString() : ' ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: buttonFontSize(),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );
    }
    timesCalled++;
    if (timesCalled == 9) {
      timesCalled = 0;
    }
    return buttonList;
  }

  Row oneRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: createButtons(),
    );
  }

  List<Row> createRows() {
    List<Row> rowList = List<Row>.generate(9, (i) => oneRow());
    return rowList;
  }

  void callback(List<int> index, int? number) {
    setState(() {
      if (number == null) {
        return;
      } else if (number == 0) {
        game[index[0]][index[1]] = number;
      } else {
        game[index[0]][index[1]] = number;
        checkResult();
      }
    });
  }

  showOptionModalSheet(BuildContext context) {
    BuildContext outerContext = context;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Styles.secondaryBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        builder: (context) {
          final TextStyle customStyle =
              TextStyle(inherit: false, color: Styles.foregroundColor);
          return Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.refresh, color: Styles.foregroundColor),
                title: Text('Restart Game', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 200), () => restartGame());
                },
              ),
              ListTile(
                leading: Icon(Icons.add_rounded, color: Styles.foregroundColor),
                title: Text('New Game', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 200),
                      () => newGame(currentDifficultyLevel!));
                },
              ),
              ListTile(
                leading: Icon(Icons.lightbulb_outline_rounded,
                    color: Styles.foregroundColor),
                title: Text('Show Solution', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      const Duration(milliseconds: 200), () => showSolution());
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.build_outlined, color: Styles.foregroundColor),
                title: Text('Set Difficulty', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      ANIMATION_DURATION_MEDIUM,
                      () => showAnimatedDialog<void>(
                          context: outerContext,
                          barrierDismissible: true,
                          duration: ANIMATION_DURATION_LONG,
                          builder: (_) => AlertDifficultyState(
                              currentDifficultyLevel!)).whenComplete(() {
                            if (AlertDifficultyState.difficulty != null) {
                              Timer(ANIMATION_DURATION_MEDIUM, () {
                                newGame(
                                    AlertDifficultyState.difficulty ?? DEFAULT_DIFFICULTY);
                                currentDifficultyLevel =
                                    AlertDifficultyState.difficulty;
                                AlertDifficultyState.difficulty = null;
                                setPrefs(PREF_DIFFICULTY_LEVEL);
                              });
                            }
                          }));
                },
              ),
              ListTile(
                leading: Icon(Icons.invert_colors_on_rounded,
                    color: Styles.foregroundColor),
                title: Text('Switch Theme', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 200), () {
                    changeTheme('switch');
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.color_lens_outlined,
                    color: Styles.foregroundColor),
                title: Text('Change Accent Color', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      const Duration(milliseconds: 200),
                      () => showAnimatedDialog<void>(
                          context: outerContext,
                          barrierDismissible: true,
                          duration: ANIMATION_DURATION_LONG,
                          builder: (_) => AlertAccentColorsState(
                              currentAccentColor!)).whenComplete(() {
                            if (AlertAccentColorsState.accentColor != null) {
                              Timer(ANIMATION_DURATION_MEDIUM, () {
                                currentAccentColor =
                                    AlertAccentColorsState.accentColor;
                                changeAccentColor(
                                    currentAccentColor!);
                                AlertAccentColorsState.accentColor = null;
                                setPrefs(PREF_ACCENT_COLOR);
                              });
                            }
                          }));
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline_rounded,
                    color: Styles.foregroundColor),
                title: Text('About', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      ANIMATION_DURATION_SHORT,
                      () => showAnimatedDialog<void>(
                          context: outerContext,
                          barrierDismissible: true,
                          duration: ANIMATION_DURATION_LONG,
                          builder: (_) => const AlertAbout()));
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: kIsWeb ? false : true,
        onPopInvokedWithResult: (didPop, result) {
          if (!kIsWeb && !didPop) {
            showAnimatedDialog<void>(
                context: context,
                barrierDismissible: true,
                duration: ANIMATION_DURATION_LONG,
                builder: (_) => const AlertExit());
          }
        },
        child: Scaffold(
            backgroundColor: Styles.primaryBackgroundColor,
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(56.0),
                child: isDesktop
                    ? MoveWindow(
                        onDoubleTap: () => appWindow.maximizeOrRestore(),
                        child: AppBar(
                          centerTitle: true,
                          title: const Text('Sudoku'),
                          backgroundColor: Styles.primaryColor,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.minimize_outlined),
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 15),
                              onPressed: () {
                                appWindow.minimize();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                              onPressed: () {
                                showAnimatedDialog<void>(
                                    context: context,
                                    barrierDismissible: true,
                                    duration: ANIMATION_DURATION_LONG,
                                    builder: (_) => const AlertExit());
                              },
                            ),
                          ],
                        ),
                      )
                    : AppBar(
                        centerTitle: true,
                        title: const Text('Sudoku'),
                        backgroundColor: Styles.primaryColor,
                      )),
            body: Builder(builder: (builder) {
              return SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Styles.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Styles.primaryColor.withValues(alpha: 0.1),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Styles.secondaryBackgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: createRows(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            floatingActionButton: FloatingActionButton(
              foregroundColor: Styles.primaryBackgroundColor,
              backgroundColor: isFABDisabled
                  ? Styles.primaryColor[900]
                  : Styles.primaryColor,
              onPressed:
                  isFABDisabled ? null : () => showOptionModalSheet(context),
              child: const Icon(Icons.menu_rounded),
            )));
  }
}
