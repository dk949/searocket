module hooks.preexec;

import common;
import hooks.common;
import hooks.checkenv;
import storage;

import std.stdio;
import std.datetime;

public:
int preExec() {
    store[Prop.Exec] = 1;
    store[Prop.StartTime] = Clock.currStdTime;
    return 0;
}
