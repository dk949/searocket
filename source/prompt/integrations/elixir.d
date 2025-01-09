module prompt.integrations.elixir;

// Note: untested
version (elixir) {
    import prompt.integrations.common: findFile;
    import storage: store, Prop, storeAs;

    import std.array: Appender;

    void checkElixir() {
        store[Prop.InElixirProject] = findFile("mix.exs").storeAs!bool;
    }

    void buildElixir(alias start)(ref Appender!string a) {

    }

}
