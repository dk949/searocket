module prompt.integrations.ruby;

// Note: untested
version (ruby) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

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
