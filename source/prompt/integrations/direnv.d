module prompt.integrations.direnv;
version (direnv) {
    import storage: store, Prop;
    import config: DIRENV_COLOR, DIRENV_SYMBOL;
    import common: append;

    import std.array: Appender;
    import std.process: environment;

    void checkDirenv() {
        if (!environment.get("DIRENV_DIR"))
            return;
        store[Prop.InDirenv] = "dir";
    }

    void buildDirenv(alias start)(ref Appender!string a) {
        const ver = store[Prop.InDirenv];
        if (ver != "") {
            start;
            a.put(DIRENV_COLOR);
            a.append(DIRENV_SYMBOL);
        }
    }
}
