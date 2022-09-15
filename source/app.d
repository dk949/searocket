import common;
import args;

import precommand;
import storage;

import std.algorithm;
import std.conv;
import std.datetime;
import std.file;
import std.path;
import std.process;
import std.range;
import std.stdio;
import std.traits;

int program(string[] args) {
    switch (cmd(args)) {
        case Hook.PreCommand:
            return preCommand(args.mode);
        case Hook.PreExec:
            store[Prop.Exec] = 1;
            store[Prop.StartTime] = Clock.currStdTime;
            return 0;
        case Hook.OnExit:
            remove(store.name);
            return 0;
        default:
            dbgthrow!Exception("Unknown Hook enum member");
    }
}

int main(string[] args) {
    debug {
        try
            return program(args);
        catch (Exception e) {
            writeln("ERROR: ", e.msg);
            return 2;
        }
    } else {
        return program(args);
    }
}
