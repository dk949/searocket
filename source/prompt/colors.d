module prompt.colors;
enum {
    Default = "%F{default}",

    Black = "%F{black}",
    Red = "%F{red}",
    Green = "%F{green}",
    Yellow = "%F{yellow}",
    Blue = "%F{blue}",
    Magenta = "%F{magenta}",
    Cyan = "%F{cyan}",
    White = "%F{white}",

    BoldBlack = "%B%F{black}%b",
    BoldRed = "%B%F{red}%b",
    BoldGreen = "%B%F{green}%b",
    BoldYellow = "%B%F{yellow}%b",
    BoldBlue = "%B%F{blue}%b",
    BoldMagenta = "%B%F{magenta}%b",
    BoldCyan = "%B%F{cyan}%b",
    BoldWhite = "%B%F{white}%b",

    UnderBlack = "%U%F{black}%u",
    UnderRed = "%U%F{red}%u",
    UnderGreen = "%U%F{green}%u",
    UnderYellow = "%U%F{yellow}%u",
    UnderBlue = "%U%F{blue}%u",
    UnderMagenta = "%U%F{magenta}%u",
    UnderCyan = "%U%F{cyan}%u",
    UnderWhite = "%U%F{white}%u",

    StandoutBlack = "%S%F{black}%s",
    StandoutRed = "%S%F{red}%s",
    StandoutGreen = "%S%F{green}%s",
    StandoutYellow = "%S%F{yellow}%s",
    StandoutBlue = "%S%F{blue}%s",
    StandoutMagenta = "%S%F{magenta}%s",
    StandoutCyan = "%S%F{cyan}%s",
    StandoutWhite = "%S%F{white}%s",
}

string colorify(string c) {
    return "%F{" ~ c ~ "}";
}
