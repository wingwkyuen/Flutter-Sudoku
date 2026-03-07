/// Game board constants
const int BOARD_SIZE = 9;
const int GRID_SIZE = 3;

/// Difficulty level empty squares
const int TEST_EMPTY_SQUARES = 2;
const int BEGINNER_EMPTY_SQUARES = 18;
const int EASY_EMPTY_SQUARES = 27;
const int MEDIUM_EMPTY_SQUARES = 42;
const int HARD_EMPTY_SQUARES = 54;
const int EXPERT_EMPTY_SQUARES = 52;
const int MIN_EMPTY_SQUARES = 17;

/// Animation durations
const Duration ANIMATION_DURATION_SHORT = Duration(milliseconds: 200);
const Duration ANIMATION_DURATION_MEDIUM = Duration(milliseconds: 300);
const Duration ANIMATION_DURATION_LONG = Duration(milliseconds: 350);
const Duration ANIMATION_DURATION_SPLASH = Duration(seconds: 2);
const Duration ANIMATION_DURATION_CHECK_RESULT = Duration(milliseconds: 500);

/// UI dimensions (mobile)
const double BUTTON_SIZE_MOBILE = 38.0;
const double BUTTON_FONT_SIZE_MOBILE = 22.0;

/// UI dimensions (desktop)
const double BUTTON_SIZE_DESKTOP = 50.0;
const double BUTTON_FONT_SIZE_DESKTOP = 28.0;

/// Window constraints
const double WINDOW_MIN_SIZE = 625.0;

/// Preference keys
const String PREF_DIFFICULTY_LEVEL = 'currentDifficultyLevel';
const String PREF_THEME = 'currentTheme';
const String PREF_ACCENT_COLOR = 'currentAccentColor';

/// Default values
const String DEFAULT_DIFFICULTY = 'hard';
const String DEFAULT_THEME = 'dark';
const String DEFAULT_ACCENT_COLOR = 'Blue';

/// Platform identifiers
const String PLATFORM_ANDROID = 'android';
const String PLATFORM_IOS = 'ios';
const String PLATFORM_WEB = 'web';
const String PLATFORM_WINDOWS = 'windows';
const String PLATFORM_LINUX = 'linux';
const String PLATFORM_MACOS = 'macos';

/// Theme options
const String THEME_LIGHT = 'light';
const String THEME_DARK = 'dark';

/// UI text
const String APP_TITLE = 'Sudoku';
const String APP_VERSION = '1.0.0';
const String DEVELOPER_NAME = 'Wing WK Yuen';
