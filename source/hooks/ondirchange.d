module hooks.ondirchange;
import common;
import hooks.common;

import storage;

import std.array;
import std.path;
import std.file;
import std.process;
import std.stdio;
import std.algorithm;

public:
int onDirChange(Mode mode) {
    assert(mode != Mode.Rprompt);

    return 0;
}

