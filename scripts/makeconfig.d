import std.stdio: stderr, stdout;
import std.file: write, mkdirRecurse, exists, isDir, dirEntries, SpanMode, FileException;
import std.process: execute, environment, ProcessException;
import std.path: chainPath, buildPath, baseName, expandTilde;
import std.array: array;
import std.algorithm: canFind, splitter;
import std.uni: asLowerCase;

enum HasNerdFont {
    No = 0,
    Yes = 1,
    Unknown
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
    if (args.length != 2) {
        stderr.writeln("Expected 2 arguments, got ", cast(int) args.length - 1);
        return -1;
    }
    args[1].mkdirRecurse();
    switch (hasNerdFont) {
        case HasNerdFont.Yes:
            args[1].chainPath("use_icons").array.write("LanguageIcons.Yes");
            stdout.writeln("Note: Detected a Nerd font, using devicons");
            break;
        case HasNerdFont.No:
            stderr.writeln("Warning: Did not detect a Nerd font, using Emoji icons");
            goto default;
        case HasNerdFont.Unknown:
            stderr.writeln(
                "Warning: No fc-list and no font directories found, could not detect a Nerd font, using Emoji"
            );
            goto default;
        default:
            args[1].chainPath("use_icons").array.write("LanguageIcons.Emoji");
            break;
    }

    return 0;
}
