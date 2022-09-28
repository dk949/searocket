module prompt.integrations.bun;
version (bun) {
    import prompt.integrations.common;
    import storage;
    import config;
    import common;

    import std.path;
    import std.array;

    void checkBun() {

        if (!findFile!(d => d.name.baseName == "bun.lockb" || d.name.baseName == "bunfig.toml")) {
            store[Prop.InBunProject] = "";
            return;
        }
        static if (BUN_DETECT_VERSION == true)
            store[Prop.InBunProject] = versionString!"bun";
        else
            store[Prop.InBunProject] = "bun";

    }

    void buildBun(alias start)(ref Appender!string a) {
        const ver = store[Prop.InBunProject];
        if (ver != "") {
            start;
            a.put(BUN_COLOR);
            if (ver == "bun")
                a.append(BUN_SYMBOL);
            else
                a.append(BUN_SYMBOL, "@", ver);
        }

    }
}
