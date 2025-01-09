module prompt.integrations.rust;

// Note: untested
version (rust) {
    import prompt.integrations.common: findFile;
    import storage: store, Prop, storeAs;

    import std.array: Appender;

    void checkRust() {
        store[Prop.InRustProject] = findFile("Cargo.toml").storeAs!bool;
    }

    void buildRust(alias start)(ref Appender!string a) {

    }

}
