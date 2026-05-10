module prompt.integrations.nix;
version (nix) {
    import storage: store, Prop;
    import config: NIX_COLOR, NIX_SYMBOL;
    import common: append;

    import std.array: Appender;
    import std.process: environment;

    void checkNix() {
        if (!environment.get("IN_NIX_SHELL"))
            store[Prop.InNixProject] = "";
        else
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
