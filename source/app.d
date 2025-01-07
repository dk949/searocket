import common;
import args;

import precommand;
import storage;
import prompt;

import std.algorithm;
import std.conv;
import std.datetime;
import std.file;
import std.path;
import std.process;
import std.range;
import std.stdio;
import std.traits;

import core.memory;

int program(string[] args) {
    int ret = 0;
    final switch (cmd(args)) {
        case Hook.PreCommand:
            ret = preCommand(args.mode);
            break;
        case Hook.PreExec:
            store[Prop.Exec] = true.storeAs!bool;
            store[Prop.StartTime] = Clock.currStdTime.storeAs!string;
            break;
        case Hook.OnExit:
            remove(store.name);
            break;
    }

    store.writeout();

    return ret;
}

int main(string[] args) {
    version(nogc) GC.disable;
    version (timing) {
        import std.datetime.stopwatch;

        auto sw = StopWatch(AutoStart.yes);
        scope (exit) {
            sw.stop;
            write("Total execution time: ", sw.peek, " >");
        }
    }

    debug {
        try
            return program(args);
        catch (Exception e) {
            writeln("ERROR: ", e);
            return 2;
        }
    } else {
        return program(args);
    }
}
