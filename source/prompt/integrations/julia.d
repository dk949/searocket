module prompt.integrations.julia;

// Note: untested
version (julia) {
    import prompt.integrations.common: findFile;
    import storage: store, Prop, storeAs;

    import std.path: baseName;
    import std.array: Appender;

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
