module prompt.integrations.bun;
version (bun) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

    void checkBun() {
        store[Prop.InBunProject] = findFile!(
            d =>
                d.name.baseName == "bun.lockb"
                || d.name.baseName == "bunfig.toml"
        ).storeAs!bool;
    }

    void buildBun(alias start)(ref Appender!string a){

    }
}
