module prompt.integrations.nodejs;
version (nodejs) {

    import prompt.integrations.common;
    import storage;
    import common;
    import config;

    import std.string;
    import std.file;
    import std.array;

    void checkNodejs() {
        string ver;
        if (auto nvmrc = findFile(".nvmrc")) {
            static if (NODE_DETECT_VERSION == NodeDetectVersion.Yes)
                ver = detectVersion;
            else
                ver = readText(nvmrc).strip;
        } else if (findFile("package.json")) {
            static if (NODE_DETECT_VERSION == NodeDetectVersion.Yes
                || NODE_DETECT_VERSION == NodeDetectVersion.IfNoNvmrc)
                ver = detectVersion;
            else
                ver = "node";
        }

        store[Prop.InNodeProject] = ver;
    }

    string detectVersion() {
        import std.process;

        const res = execute(["node", "-v"]);
        if (res.status == 0)
            return res.output.strip;
        else
            return null;

    }

    void buildNodejs(alias start)(ref Appender!string a) {
        const node = store[Prop.InNodeProject];
        if (node != "") {
            start;
            if (node == "node")
                a.put("⬢ ");
            else
                a.append("⬢ @", node);
        }
    }
}
