module prompt.integrations.java;

// Note: untested
version (java) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

    void checkJava() {
        store[Prop.InJavaProject] = findFile!(
            d =>
                d.name.baseName == "pom.xml"
                || d.name.baseName == "build.gradle"
                || d.name.baseName == "settings.gradle"
        ).storeAs!bool;
    }

    void buildJava(alias start)(ref Appender!string a) {

    }
}
