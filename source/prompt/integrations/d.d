module prompt.integrations.d;
version (d) {
    import prompt.integrations.common;
    import storage;
    import common;

    import std.algorithm;
    import std.array;
    import std.path;
    import std.process;

    void checkD() {
        const ps1 = environment.get("PS1");
        if (ps1 && ps1.length > 4) {
            // TODO: not guaranteed to work if some other environment loads after D
            //       and puts something else atthe beginning of PS1.
            if (ps1[0 .. 4] == "(dmd"
                || ps1[0 .. 4] == "(ldc"
                || ps1[0 .. 4] == "(gdc"
                ) {
                const end = countUntil(ps1[1 .. $], ')');
                if (end != -1) {
                    store[Prop.InDProject] = ps1[1 .. end + 1];
                    return;
                }
            }
        }
        store[Prop.InDProject] = findFile!(
            d =>
                d.name.baseName == "dub.json"
                || d.name.baseName == "dub.sdl"
        ) ? "D" : "";
    }

    void buildD(alias start)(ref Appender!string a) {
        const dversion = store[Prop.InDProject];
        if (dversion != "") {
            start;
            if (dversion == "D")
                a.put('D');
            else
                a.append("D@", dversion);
        }

    }
}
