module prompt.integrations.zig;
version (zig) {
    import prompt.integrations.common: findFile, versionString;
    import storage: store, Prop;
    import config: ZIG_COLOR, ZIG_SYMBOL, ZIG_DETECT_VERSION;
    import common: append;

    import std.array: Appender;
    import std.algorithm: splitter;

    void checkZig() {
        if (!findFile("build.zig")) {
            store[Prop.InZigProject] = "";
            return;
        }
        final switch (ZIG_DETECT_VERSION) {
            case true:
                if (const ver = versionString!("zig", "version")) {
                    store[Prop.InZigProject] = ver.splitter('+').front;
                    return;
                }
                goto case;
            case false:
                store[Prop.InZigProject] = "zig";
                break;
        }
    }

    void buildZig(alias start)(ref Appender!string a) {
        const ver = store[Prop.InZigProject];
        if (ver != "") {
            start;
            a.put(ZIG_COLOR);
            if (ver == "zig")
                a.append(ZIG_SYMBOL);
            else
                a.append(ZIG_SYMBOL, "@", ver);
        }

    }
}
