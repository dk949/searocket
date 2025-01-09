module prompt.integrations.php;

// Note: untested
version (php) {
    import prompt.integrations.common: findFile;
    import storage: store, Prop, storeAs;

    import std.array: Appender;

    void checkPhp() {
        store[Prop.InPhpProject] = findFile("composer.json").storeAs!bool;
    }

    void buildPhp(alias start)(ref Appender!string a) {

    }

}
