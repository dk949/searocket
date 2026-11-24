import std.stdio: stderr, stdout;
import std.file: write, mkdirRecurse, exists, isDir, dirEntries, SpanMode, FileException;
import std.process: execute, environment, ProcessException;
import std.path: chainPath, buildPath, baseName, expandTilde;
import std.array: array;
import std.algorithm: canFind, splitter;
import std.uni: asLowerCase, toLower;

enum HasNerdFont {
    No = 0,
    Yes = 1,
    Unknown
}

enum IconOverride {
    None,
    No,
    Emoji,
    Yes,
    Error,
}

IconOverride getOverride(string[] args) {
    if(args.length != 3)
        return IconOverride.None;

    switch(args[2].toLower) {
        case "no": return IconOverride.No;
        case "emoji": return IconOverride.Emoji;
        case "yes": return IconOverride.Yes;
        default: return IconOverride.Error;
    }
}

bool isANerdFont(string s) {
    return s.asLowerCase.canFind("nerd");
}

HasNerdFont queryFontconfig() {
    try {
        const r = execute(["fc-list"]);
        if (r.status != 0)
            return HasNerdFont.Unknown;
        return r.output.isANerdFont ? HasNerdFont.Yes : HasNerdFont.No;
    } catch (ProcessException e) // fc-list is not installed
        return HasNerdFont.Unknown;
}

string[] fontDirs() {
    string[] dirs;
    version (OSX) {
        dirs ~= ["~/Library/Fonts".expandTilde, "/Library/Fonts", "/System/Library/Fonts", "/Network/Library/Fonts"];
    } else version (Windows) {
        dirs ~= buildPath(environment.get("WINDIR", `C:\Windows`), "Fonts");
        if (const local = environment.get("LOCALAPPDATA"))
            dirs ~= buildPath(local, "Microsoft", "Windows", "Fonts");
    } else { // Linux, BSDs and other XDG-ish systems
        const home = environment.get("HOME", "");
        dirs ~= buildPath(environment.get("XDG_DATA_HOME", buildPath(home, ".local", "share")), "fonts");
        dirs ~= buildPath(home, ".fonts");
        foreach (d; environment.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").splitter(':'))
            dirs ~= buildPath(d, "fonts");
    }
    return dirs;
}

HasNerdFont scanFontDirs() {
    auto searchedAny = false;
    foreach (dir; fontDirs) {
        try {
            if (!dir.exists || !dir.isDir)
                continue;
            searchedAny = true;
            foreach (entry; dirEntries(dir, SpanMode.depth, false))
                if (entry.name.baseName.isANerdFont)
                    return HasNerdFont.Yes;
        } catch (FileException e) { }
    }
    return searchedAny ? HasNerdFont.No : HasNerdFont.Unknown;
}

HasNerdFont hasNerdFont() {
    const fc = queryFontconfig();
    if (fc == HasNerdFont.Yes)
        return fc;
    const scan = scanFontDirs();
    if (scan == HasNerdFont.Yes)
        return scan;
    return (fc == HasNerdFont.No || scan == HasNerdFont.No) ? HasNerdFont.No : HasNerdFont.Unknown;
}



int main(string[] args) {
    if (args.length < 2 || args.length > 3) {
        stderr.writeln("Expected 1 or 2 arguments, got ", cast(int) args.length - 1);
        return -1;
    }
    args[1].mkdirRecurse();
    string use_icons = "LanguageIcons.Emoji";
    final switch(args.getOverride()){
        case IconOverride.Error:
            stderr.writeln("Unexpected icon setting '", args[2], "' expected one of 'No', 'Emoji' or 'Yes'");
            return -1;
        case IconOverride.No:
            stdout.writeln("Note: Icon setting set to ASCII");
            use_icons = "LanguageIcons.No";
            break;
        case IconOverride.Emoji:
            stdout.writeln("Note: Icon setting set to Emoji");
            use_icons = "LanguageIcons.Emoji";
            break;
        case IconOverride.Yes:
            stdout.writeln("Note: Icon setting set to devicons");
            use_icons = "LanguageIcons.Yes";
            break;
        case IconOverride.None:
            final switch (hasNerdFont) {
                case HasNerdFont.Yes:
                    use_icons = "LanguageIcons.Yes";
                    stdout.writeln("Note: Detected a Nerd font, using devicons");
                    break;
                case HasNerdFont.No:
                    stderr.writeln("Warning: Did not detect a Nerd font, using Emoji icons");
                    break;
                case HasNerdFont.Unknown:
                    stderr.writeln(
                        "Warning: No fc-list and no font directories found, could not detect a Nerd font, using Emoji"
                    );
                    break;
            }
    }

    args[1].chainPath("use_icons").array.write(use_icons);

    return 0;
}
