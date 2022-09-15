module precommand;

import common;
import mainprompt;
import checkenv;
import storage;

import std.stdio;
import std.conv;

public:
int preCommand(Mode mode) {
    final switch (mode) {
        case Mode.Prompt:
            if (store[Prop.Exec] && store[Prop.Exec].to!int)
                checkEnv();
            writeln(mainPrompt);
            break;
        case Mode.Rprompt:
            if (store[Prop.Exec] && store[Prop.Exec].to!int) {
                store[Prop.Exec] = 0;
                writeln(mainRprompt);
            }
            break;
    }
    return 0;
}
