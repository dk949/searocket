module hooks.onexit;

import common;
import hooks.common;
import storage;
import std.file;

public:
int onExit() {
    remove(store.name);
    return 0;
}
