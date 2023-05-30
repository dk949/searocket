#!/usr/bin/env dub
/+dub.json:
{
    "name": "makeconfig"
}
+/
import std.stdio : stderr, stdout;
import std.file : write, mkdirRecurse;
import std.process : execute, executeShell;
import std.path : chainPath;
import std.array : array;

enum HasNerdFont {
    No = 0,
    Yes = 1,
    Unknown
}

HasNerdFont hasNerdFont() {
    try
        if (execute(["which", "fc-list"]).status)
            return HasNerdFont.Unknown;
        else if (executeShell("fc-list | grep -iq 'nerd'").status)
            return HasNerdFont.No;
        else
            return HasNerdFont.Yes;
    catch (Exception e)
        return HasNerdFont.Unknown;
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
                "Warning: fc-list not found, could not detect a Nerd font, using Emoji");
            goto default;
        default:
            args[1].chainPath("use_icons").array.write("LanguageIcons.Emoji");
            break;
    }

    return 0;
}
