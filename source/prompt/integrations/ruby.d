module prompt.integrations.ruby;

// Note: untested
version (ruby) {
    import prompt.integrations.common: findFile;
    import storage: store, Prop, storeAs;

    import std.path: baseName;
    import std.array: Appender;

    void checkRuby() {
        store[Prop.InRubyProject] = findFile!(
            d =>
                d.name.baseName == "Gemfile"
                || d.name.baseName == "Rakefile"
        ).storeAs!bool;
    }

    void buildRuby(alias start)(ref Appender!string a) {

    }

}
