module prompt.integrations.nodejs;
version (nodejs) {

    import prompt.integrations.common: findFile, versionString;
    import storage: store, Prop;
    import common: append;
    import config: NODE_DETECT_VERSION, NODE_COLOR, NODE_SYMBOL, NodeDetectVersion;

    import std.string: strip;
    import std.file: readText;
    import std.array: Appender;
    import std.process: execute;

    void checkNodejs() {
        string ver;
        if (auto nvmrc = findFile(".nvmrc")) {
            static if (NODE_DETECT_VERSION == NodeDetectVersion.Yes)
                ver = versionString!("node", "-v");
            else
                ver = readText(nvmrc).strip;
        } else if (findFile("package.json")) {
            static if (NODE_DETECT_VERSION == NodeDetectVersion.Yes
                || NODE_DETECT_VERSION == NodeDetectVersion.IfNoNvmrc)
                ver = versionString!("node", "-v");
            else
                ver = "node";
        }

        store[Prop.InNodeProject] = ver;
    }

    void buildNodejs(alias start)(ref Appender!string a) {
        const node = store[Prop.InNodeProject];
        if (node != "") {
            start;
            a.put(NODE_COLOR);
            if (node == "node")
                a.put(NODE_SYMBOL);
            else
                a.append(NODE_SYMBOL, "@", node);
        }
    }
}
