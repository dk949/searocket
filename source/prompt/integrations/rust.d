module prompt.integrations.rust;

// Note: untested
version (rust) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

    void checkRust() {
        store[Prop.InRustProject] = findFile("Cargo.toml").storeAs!bool;
    }

    void buildRust(alias start)(ref Appender!string a) {

    }

}
