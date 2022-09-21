module prompt.integrations.elixir;

// Note: untested
version (elixir) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

    void checkElixir() {
        store[Prop.InElixirProject] = findFile("mix.exs").storeAs!bool;
    }

    void buildElixir(alias start)(ref Appender!string a) {

    }

}
