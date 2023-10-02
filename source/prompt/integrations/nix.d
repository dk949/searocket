module prompt.integrations.nix;
version (nix) {
    import storage;

    import config;
    import common;

    import std.array;
    import std.process;

    void checkNix() {

        if (!environment.get("IN_NIX_SHELL"))
            return;
        store[Prop.InNixProject] = "nix";
    }

    void buildNix(alias start)(ref Appender!string a) {
        const ver = store[Prop.InNixProject];
        if (ver != "") {
            start;
            a.put(NIX_COLOR);
            a.append(NIX_SYMBOL);
        }
    }
}
