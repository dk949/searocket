module precommand;

import prompt: Mode, checkGit, checkEnv, mainPrompt, mainRprompt;
import storage: store, storeAs, Prop;

import std.stdio: writeln;
import std.conv: to;

public:
int preCommand(Mode mode) {
    final switch (mode) {
        case Mode.Prompt:
            if (store[Prop.Exec] && store[Prop.Exec].to!int) {
                version (git)
                    checkGit();
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
