module precommand;

import common;
import prompt;
import storage;

import std.stdio;
import std.conv;

public:
int preCommand(Mode mode) {
    final switch (mode) {
        case Mode.Prompt:
            if (store[Prop.Exec] && store[Prop.Exec].to!int) {
                version(git) checkGit();
                checkEnv();
            }
            writeln(mainPrompt);
            break;
        case Mode.Rprompt:
            version (took) {
                if (store[Prop.Exec] && store[Prop.Exec].to!int) {
                    store[Prop.Exec] = false.storeAs!bool;
                    writeln(mainRprompt);
                }
            }
            break;
    }
    return 0;
}
