module prompt.integrations.php;

// Note: untested
version (php) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

    void checkPhp() {
        store[Prop.InPhpProject] = findFile("composer.json").storeAs!bool;
    }

    void buildPhp(alias start)(ref Appender!string a) {

    }

}
