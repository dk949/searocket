module prompt.integrations.elm;

version (elm) {
    import prompt.integrations.common;
    import storage;
    import common;
    import config;

    import std.path;
    import std.string;
    import std.process;
    import std.conv;
    import std.array;

    void checkElm() {
        string ver = "";
        if (auto elmjson = findFile!(d =>
                d.name.baseName == "elm.json"
                || d.name.baseName == "elm-package.json"
                || d.name.baseName == "elm-stuff" ? d.name : null)) {
            static if (ELM_DETECT_VERSION == ElmDetectVersion.Yes)
                ver = versionString!"elm";
            else static if (ELM_DETECT_VERSION == ElmDetectVersion.IfNoElmJson)
                ver = detectVersionElmJson(elmjson);
        }
        store[Prop.InElmProject] = ver;
    }

    void buildElm(alias start)(ref Appender!string a) {
        const elmVer = store[Prop.InElmProject];
        if (elmVer != "") {
            start;
            a.put(ELM_COLOR);
            a.append(ELM_SYMBOL);
            if (elmVer != "elm")
                a.append("@", elmVer);
        }
    }

    private string detectVersionElmJson(string file) {
        import std.json;
        import std.file;

        const json = file.readText.parseJSON;
        if ("elm-version" in json) {
            return json["elm-version"].str;
        } else
            return null;
    }
}
