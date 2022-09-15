module hooks.onexit;

import common;
import hooks.common;
import storage;
import std.file;

public:
int onExit(Mode mode) {
    assert(mode == Mode.Prompt);
    remove(store.name);
    return 0;
}
