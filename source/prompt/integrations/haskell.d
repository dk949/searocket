module prompt.integrations.haskell;

// Note: untested
version (haskell) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

    void checkHaskell() {
        store[Prop.InHaskellProject] = findFile("stack.yalm").storeAs!bool;
    }

    void buildHaskell(alias start)(ref Appender!string a) {

    }

}
