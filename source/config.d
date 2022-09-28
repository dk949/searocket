/*
 _____ ____ ___ _____      __  __ _____
| ____|  _ \_ _|_   _|    |  \/  | ____|
|  _| | | | | |  | |      | |\/| |  _|
| |___| |_| | |  | |      | |  | | |___
|_____|____/___| |_|      |_|  |_|_____|
*/

module config;
import prompt.colors;

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

version(took) enum{
    TOOK_CHAR = "❮",
    TOOK_CHAR_COLOR = Green,
    TOOK_TEXT_COLOR = Default,
    TOOK_TIME_COLOR = Yellow,
}

version (exitcode) enum {
    EXIT_CODE_COLOR = BoldRed,
}
