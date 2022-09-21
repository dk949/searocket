module prompt.integrations.julia;

// Note: untested
version (julia) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

    void checkJulia() {
        store[Prop.InJuliaProject] = findFile!(
            d =>
                d.name.baseName == "Project.toml"
                || d.name.baseName == "JuliaProject.toml "
                || d.name.baseName == "Manifest.toml"
        ).storeAs!bool;
    }

    void buildJulia(alias start)(ref Appender!string a) {

    }
}
