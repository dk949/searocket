module prompt.integrations.elm;

// Note: untested
version (elm) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

    void checkElm() {
        store[Prop.InElmProject] = findFile!(
            d =>
                d.name.baseName == "elm.json"
                || d.name.baseName == "elm-package.json"
                || d.name.baseName == "elm-stuff"
        ).storeAs!bool;
    }

    void buildElm(alias start)(ref Appender!string a) {

    }

}
