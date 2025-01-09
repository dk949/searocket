module args;

debug import common: dbgthrow;
import prompt: Hook, Mode;

import std.algorithm: canFind;
import std.range: only;
import std.traits: EnumMembers;

Hook cmd(string[] args) {
    debug {
        if (args.length < 2)
            dbgthrow!Exception("Too few args");
        if (!only(EnumMembers!Hook).canFind(args[1]))
            dbgthrow!Exception("Invalid hook " ~ args[1]);
    }
    return cast(Hook) args[1];
}

Mode mode(string[] args) {
    debug {
        if (args.length < 3)
            dbgthrow!Exception("Too few args");
        if (!only(EnumMembers!Mode).canFind(args[2]))
            dbgthrow!Exception("Invalid mode " ~ args[2]);
    }
    return cast(Mode) args[2];
}
