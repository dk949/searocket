module prompt.integrations.haskell;

// Note: untested
version (haskell) {
    import prompt.integrations.common: findFile;
    import storage: store, Prop, storeAs;

    import std.array: Appender;

    void checkHaskell() {
        store[Prop.InHaskellProject] = findFile("stack.yalm").storeAs!bool;
    }

    void buildHaskell(alias start)(ref Appender!string a) {

    }

}
