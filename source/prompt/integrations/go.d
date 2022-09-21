module prompt.integrations.go;

// Note: untested
version (go) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

    void checkGo() {
        store[Prop.InGoProject] = findFile!(
            d =>
                d.name.baseName == "go.mod"
                || d.name.baseName == "Gopkg.toml"
                || d.name.baseName == "Gopkg.lock"
                || d.name.baseName == "glide.yaml"
                || d.name.baseName == "Godeps"
        ).storeAs!bool;
    }

    void buildGo(alias start)(ref Appender!string a) {

    }

}
