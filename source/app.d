import args: cmd, mode;
import precommand: preCommand;
import storage: store, storeAs, Prop;
import prompt: Hook;

import std.conv: to;
import std.datetime: Clock;
import std.file: remove;

import core.memory: GC;

version (timing) {
    import std.datetime.stopwatch: StopWatch, AutoStart;
    import std.stdio: write;
}
debug {
    import std.stdio: stderr;
}

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
    version (nogc)
        GC.disable;
    version (timing) {
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
            stderr.writeln("ERROR: ", e);
            return 2;
        }
    } else {
        return program(args);
    }
}
