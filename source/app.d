import common;
import args;

import hooks;

import std.stdio;
import std.traits;
import std.range;
import std.algorithm;
import std.path;
import std.file;
import std.conv;
import std.process;

int program(string[] args) {
    switch (cmd(args)) {
        case Hook.PreCommand:
            return preCommand(args.mode);
        case Hook.PreExec:
            return preExec(args.mode);
        case Hook.OnExit:
            return onExit(args.mode);
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
