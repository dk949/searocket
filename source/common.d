module common;

import std.conv: text;
import std.traits: isInstanceOf;
import std.array: Appender;
import std.stdio: stderr;

noreturn dbgthrow(E, Args...)(Args msg)
if (__traits(compiles, new E(msg)) && __traits(compiles, text(msg))) {

    debug {
        throw new E(msg);
    } else {
        assert(0, text(msg));
    }
    assert(0, "?????");
}

void dbgwarn(Args...)(Args msg) {
    debug stderr.writeln("[WARNING]: ", msg);
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
