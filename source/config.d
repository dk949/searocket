/*
 _____ ____ ___ _____      __  __ _____
| ____|  _ \_ _|_   _|    |  \/  | ____|
|  _| | | | | |  | |      | |\/| |  _|
| |___| |_| | |  | |      | |  | | |___
|_____|____/___| |_|      |_|  |_|_____|
*/

module config;
public import configutils;
import prompt.colors;
import std.datetime;

// To enable a section of this config, add the `version` to the `versions` list in `dub.json`

enum {
    PROMPT_CHAR = " ❯ ",

    // Coming soon
    INCOMPLETE_CMD_CHAR = PROMPT_CHAR,

    SUCCESS_COLOR = Green,
    FAILURE_COLOR = BoldRed,
    // Coming soon
    INCOMPLETE_CMD_COLOR = Yellow,
}

version (user) enum {
    SHOW_USER = UsrShow.Yes,
    USER_COLOR = Yellow,
    ROOT_USER_COLOR = UnderRed,
}
// 0 means do not truncate
version (dir) enum {
    DIR_TRUNCATION = 0,
    DIR_COLOR = Cyan,

    // Coming soon
    DIR_LOCK_CHAR_COLOR = Red,
    // Coming soon
    DIR_LOCK_CHAR = "",
}

version (jobs) enum {
    JOBS_CHAR = "✦",
    JOBS_COLOR = Blue,
}

version (took) enum {
    TOOK_CHAR = "❮",
    TOOK_CHAR_COLOR = Green,
    TOOK_TEXT_COLOR = Default,
    TOOK_TIME_COLOR = Yellow,
    TOOK_THRESHOLD = dur!"seconds"(2),
}

version (exitcode) enum {
    EXIT_CODE_COLOR = BoldRed,
}

// Integraions

enum {
    INTEGRATION_COLOR = Blue,
    INTEGRATION_START_CHAR = '[',
    INTEGRATION_END_CHAR = ']',
    /* how many integrations are shown in a line before prompt is split in to 2
       lines. 0 for no limit. Note: Propmt may become dificult to use if too
       many integrations are present on a single line. */
    INTEGRATION_MAX_INLINE = 3,

}

// Not yet implemented
version (battery) enum {
    BATTERY_SHOW = BatteryShow.Low,
    BATTERY_CHARGING_CHAR = "+",
    BATTERY_DISCHARGING_CHAR = "-",
    BATTERY_FULL_CHAR = "",
    BATTERY_THRESHOLD = 20,
}
version (bun) enum {
    BUN_SYMBOL = "🍞",
    BUN_COLOR = "#fbf0df".colorify,
    BUN_DETECT_VERSION = true,
}
version (d) enum {
    D_SYMBOL = "🇩 ",
    D_COLOR = Red,
    D_DETECT_VERSION = DDetectVersion.IfNoPS1,
    /* If D_DETECT_VERSION == Yes or IfNoPS1, what order to try compilers in.
       First compiler that exists is used. */
    D_COMPILER_ORDER = ["ldc", "dmd", "gdc"],
}
// Not yet implemented
version (docker) enum {
    DOCKER_SYMBOL = "🐳",
    DOCKER_COLOR = Cyan,
}
// Not yet implemented
version (elixir) enum {
    ELIXIR_SYMBOL = "💧",
    ELIXIR_COLOR = Magenta,
    ELIXIR_DETECT_VERSION = true,
}
version (elm) enum {
    ELM_SYMBOL = "🌳",
    ELM_COLOR = Cyan,
    ELM_DETECT_VERSION = ElmDetectVersion.IfNoElmJson,
}
version (git) enum {
    GIT_CHAR = "  ",
    GIT_COLOR = Magenta,
    GIT_STATUS_COLOR = Red,
    GIT_UNTRACKED_CHAR = "?",
    GIT_ADDED_CHAR = "+",
    GIT_MODIFIED_CHAR = "!",
    GIT_RENAMED_CHAR = "»",
    GIT_DELETED_CHAR = "✘",
    GIT_STASHED_CHAR = "$",
    GIT_UNMERGED_CHAR = "=",
    GIT_AHEAD_CHAR = "⇡",
    GIT_BEHIND_CHAR = "⇣",
    GIT_DIVERGED_CHAR = "⇕",
}
version (go) enum {
    GO_SYMBOL = "🐹",
    GO_COLOR = Cyan,
    GO_DETECT_VERSION = GoDetectVersion.Yes,
}
// Not yet implemented
version (haskell) enum {
    HASKELL_SYMBOL = "λ",
    HASKELL_COLOR = Blue,
    HASKELL_DETECT_VERSION = HaskellDetectVersion.IfNoStackYaml,
}
// Not yet implemented
version (java) enum {
    JAVA_SYMBOL = "♨️ ",
    JAVA_COLOR = Red,
    JAVA_DETECT_VERSION = true,
}
// Not yet implemented
version (julia) enum {
    JULIA_SYMBOL = "ஃ",
    JULIA_COLOR = Green,
    JULIA_DETECT_VERSION = true,
}
version (nodejs) enum {
    NODE_SYMBOL = "⬢ ",
    NODE_COLOR = Green,
    NODE_DETECT_VERSION = NodeDetectVersion.IfNoNvmrc,
}
// Not yet implemented
version (php) enum {
    PHP_SYMBOL = "🐘",
    PHP_COLOR = Blue,
    PHP_DETECT_VERSION = true,
}
version (python) enum {
    PYTHON_SYMBOL = "🐍",
    PYTHON_COLOR = Yellow,
    PYTHON_DETECT_VERSION = PythonDetectVersion.IfNoVenv,
}
// Not yet implemented
version (ruby) enum {
    RUBY_SYMBOL = "💎",
    RUBY_COLOR = Red,
    RUBY_DETECT_VERSION = RubyDetectVersion.IfNoGemfile,
}
// Not yet implemented
version (rust) enum {
    RUST_SYMBOL = "🦀",
    RUST_COLOR = Red,
    RUST_DETECT_VERSION = RustDetectVersion.IfNoConfigToml,
}
// Not yet implemented
version (swift) enum {
    SWIFT_SYMBOL = "🐦",
    SWIFT_COLOR = Yellow,
    SWIFT_DETECT_VERSION = RubyDetectVersion.IfNoGemfile,
}
// Not yet implemented
version (xcode) enum {
    XCODE_SYMBOL = "🛠 ",
    XCODE_COLOR = Blue,
    XCODE_DETECT_VERSION = RubyDetectVersion.IfNoGemfile,
}
version (zig) enum {
    ZIG_SYMBOL = "🇿 ",
    ZIG_COLOR = Yellow,
    ZIG_DETECT_VERSION = true,
}
