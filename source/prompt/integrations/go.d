module prompt.integrations.go;

// Note: untested
version (go) {
    import prompt.integrations.common: findFile, versionString;
    import storage: store, Prop;
    import common: append;
    import config: GO_COLOR, GO_SYMBOL, GO_DETECT_VERSION, GoDetectVersion;

    import std.file: readText;
    import std.path: baseName;
    import std.array: Appender;
    import std.algorithm: splitter, filter;
    import std.range: drop;

    void checkGo() {
        const file = findFile!(
            d =>
                d.name.baseName == "go.mod" ? d.name
                : d.name.baseName == "Gopkg.toml"
                || d.name.baseName == "Gopkg.lock"
                || d.name.baseName == "glide.yaml"
                || d.name.baseName == "Godeps" ? "go" : null
        );
        if (!file) {
            store[Prop.InGoProject] = "";
            return;
        }
        final switch (GO_DETECT_VERSION) {
            case GoDetectVersion.IfNoGoMod:
                if (file == "go")
                    goto case;
                if (const ver = file.versionFromFile) {
                    store[Prop.InGoProject] = ver;
                    return;
                }
                goto case;
            case GoDetectVersion.Yes:
                if (const ver = detectVersion) {
                    store[Prop.InGoProject] = ver;
                    return;
                }
                goto case;
            case GoDetectVersion.No:
                store[Prop.InGoProject] = "go";
                break;
        }
    }

    void buildGo(alias start)(ref Appender!string a) {
        const ver = store[Prop.InGoProject];
        if (ver != "") {
            start;
            a.put(GO_COLOR);
            if (ver == "go")
                a.append(GO_SYMBOL);
            else
                a.append(GO_SYMBOL, "@", ver);
        }

    }

    private string versionFromFile(string file) {
        return versionFromFileImpl(file.readText);
    }

    private string versionFromFileImpl(string contents) {
        return contents
            .splitter('\n')
            .filter!(line => line.length >= 2 && line[0 .. 2] == "go")
            .front[3 .. $];
    }

    private string detectVersion() {
        return detectVersionImpl!versionString();

    }

    private string detectVersionImpl(alias getVer)() {

        auto ver = getVer!("go", "version");
        if (!ver)
            return null;
        ver = ver.splitter(' ').drop(2).front;
        if (ver.length <= 2)
            return null;
        else
            return ver[2 .. $];
    }

    unittest {
        string getVer(string _, string __)() {
            return `go version go1.19.1 linux/amd64
`;
        }

        const res = detectVersionImpl!getVer();
        assert(res == "1.19.1");
    }

    unittest {
        string contents = `module github.com/USERNAME/simple-go-service

go 1.19
`;
        const res = versionFromFileImpl(contents);
        assert(res == "1.19");
    }
}
