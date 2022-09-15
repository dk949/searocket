module common;

public import hooks.mainprompt: Hook, Mode;

import std.process;
import std.functional;
import std.conv;

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
