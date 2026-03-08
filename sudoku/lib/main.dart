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
    // Helper to count occurrences of each number in the board
    Map<int, int> getNumberCounts() {
      Map<int, int> counts = {for (var i = 1; i <= 9; i++) i: 0};
      for (var row in game) {
        for (var val in row) {
          if (val >= 1 && val <= 9) {
            counts[val] = counts[val]! + 1;
          }
        }
      }
      return counts;
    }

    Widget buildNumberBar() {
      final counts = getNumberCounts();
      return Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int n = 1; n <= 9; n++)
              GestureDetector(
                onTap: () {
                  setState(() {
                    barHighlightNumber = (barHighlightNumber == n) ? null : n;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: barHighlightNumber == n
                        ? Colors.blue[200]
                        : (counts[n] == 9 ? Colors.amberAccent : Styles.primaryBackgroundColor),
                    border: Border.all(
                      color: barHighlightNumber == n
                          ? Colors.blue
                          : (counts[n] == 9 ? Colors.orange : Styles.primaryColor),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Text(
                      n.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: barHighlightNumber == n
                            ? Colors.blue[900]
                            : (counts[n] == 9 ? Colors.deepOrange : Styles.primaryColor),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  bool firstRun = true;
  bool gameOver = false;
  int timesCalled = 0;
  bool isButtonDisabled = false;
  bool isFABDisabled = false;
  int? selectedNumber;
  int? barHighlightNumber;
  Timer? gameTimer;
  int elapsedSeconds = 0;
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
  static bool isDesktop =
      [PLATFORM_WINDOWS, PLATFORM_LINUX, PLATFORM_MACOS].contains(platform);

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

  @override
  void dispose() {
    stopTimer();
    super.dispose();
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
        stopTimer();
        final completionTime = formatTime(elapsedSeconds);
        Timer(ANIMATION_DURATION_CHECK_RESULT, () {
          showAnimatedDialog<void>(
                  context: context,
                  barrierDismissible: true,
                  duration: ANIMATION_DURATION_LONG,
                  builder: (_) => AlertGameOver(timeString: completionTime))
              .whenComplete(() {
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
        debugPrint(
            'Failed to generate puzzle with $currentEmpty empty squares: $e');
        retryCount++;
        currentEmpty =
            (currentEmpty - 2).clamp(MIN_EMPTY_SQUARES, emptySquares);
        if (retryCount >= maxRetries) {
          debugPrint(
              'Could not generate valid puzzle after $maxRetries retries');
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
      game = List<List<int>>.generate(9, (_) => List<int>.filled(9, 0));
      gameCopy = List<List<int>>.generate(9, (_) => List<int>.filled(9, 0));
      gameSolved = List<List<int>>.generate(9, (_) => List<int>.filled(9, 0));
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
      selectedNumber = null;
    });
    stopTimer();
  }

  void newGame([String difficulty = 'easy']) {
    setState(() {
      isFABDisabled = !isFABDisabled;
      selectedNumber = null;
    });
    Future.delayed(const Duration(milliseconds: 200), () async {
      await setGame(2, difficulty);
      setState(() {
        isButtonDisabled =
            isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
        gameOver = false;
        isFABDisabled = !isFABDisabled;
      });
      resetTimer();
      startTimer();
    });
  }

  void restartGame() {
    setState(() {
      game = copyGrid(gameCopy);
      isButtonDisabled =
          isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
      gameOver = false;
      selectedNumber = null;
    });
    resetTimer();
    startTimer();
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  void stopTimer() {
    gameTimer?.cancel();
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      elapsedSeconds = 0;
    });
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  List<Widget> createButtons() {
    if (firstRun) {
      setGame(1);
      firstRun = false;
    }

    List<Widget> buttonList = List<Widget>.filled(9, const SizedBox());
    for (var i = 0; i <= 8; i++) {
      var k = timesCalled;
      buttonList[i] = Container(
        key: Key('grid-button-$k-$i'),
        width: buttonSize(),
        height: buttonSize(),
        decoration: BoxDecoration(
          color: buttonColor(k, i, game, gameCopy, null, null, barHighlightNumber ?? selectedNumber),
          border: getGridBorder(k, i),
        ),
        child: TextButton(
          onPressed: isButtonDisabled
              ? null
              : () {
                  // If it's a clue cell, only highlight matching numbers
                  if (gameCopy[k][i] != 0) {
                    setState(() {
                      selectedNumber =
                          selectedNumber == game[k][i] ? null : game[k][i];
                    });
                  } else if (game[k][i] != 0) {
                    // Cell has user-input number - allow both highlighting and editing
                    // Show dialog to change the number
                    showAnimatedDialog<void>(
                            context: context,
                            barrierDismissible: true,
                            duration: ANIMATION_DURATION_MEDIUM,
                            builder: (_) => AlertNumbersState(currentValue: game[k][i]))
                        .whenComplete(() {
                      callback([k, i], AlertNumbersState.number);
                      AlertNumbersState.number = null;
                    });
                  } else {
                    // Empty cell - show number input dialog
                    showAnimatedDialog<void>(
                            context: context,
                            barrierDismissible: true,
                            duration: ANIMATION_DURATION_MEDIUM,
                            builder: (_) => AlertNumbersState(currentValue: game[k][i]))
                        .whenComplete(() {
                      callback([k, i], AlertNumbersState.number);
                      AlertNumbersState.number = null;
                    });
                  }
                },
          onLongPress: isButtonDisabled || gameCopy[k][i] != 0
              ? null
              : () {
                  callback([k, i], 0);
                  setState(() {
                    selectedNumber = null;
                  });
                },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
            foregroundColor:
                WidgetStateProperty.all<Color>(Styles.foregroundColor),
            shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            elevation: WidgetStateProperty.all<double>(0),
            shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
            overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
            padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
          ),
          child: Center(
            child: Text(
              game[k][i] != 0 ? game[k][i].toString() : ' ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: buttonFontSize(),
                fontWeight: FontWeight.bold,
                color: gameCopy[k][i] != 0
                    ? Styles.foregroundColor // Original clue numbers
                    : Styles.primaryColor, // User-input numbers
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
        selectedNumber = null;
      } else {
        game[index[0]][index[1]] = number;
        selectedNumber = null;
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
                                newGame(AlertDifficultyState.difficulty ??
                                    DEFAULT_DIFFICULTY);
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
                                changeAccentColor(currentAccentColor!);
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...createRows(),
                        buildNumberBar(),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Styles.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Styles.primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: Styles.primaryColor,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                formatTime(elapsedSeconds),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Styles.foregroundColor,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
