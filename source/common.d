module common;

public import mainprompt: Hook, Mode;

import std.process;
import std.functional;
import std.conv;
import std.traits;
import std.array;

noreturn dbgthrow(E, Args...)(Args msg)
if (__traits(compiles, new E(msg)) && __traits(compiles, text(msg))) {

    debug {
        throw new E(msg);
    } else {
        assert(0, text(msg));
    }
    assert(0, "?????");
}

version (Windows)
    enum EOL = "\r\n";
else
    enum EOL = "\n";

void append(T, Args...)(ref T a, auto ref Args args)
if (isInstanceOf!(Appender, T)) {
    foreach (arg; args) {
        a.put(arg);
    }
}
