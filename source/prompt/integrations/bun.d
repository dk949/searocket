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
        final switch (BUN_DETECT_VERSION) {
            case true:
                if (const ver = versionString!"bun") {
                    store[Prop.InBunProject] = ver;
                    return;
                }
                goto case;
            case false:
                store[Prop.InBunProject] = "bun";
                break;
        }
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
