module prompt.integrations.java;

// Note: untested
version (java) {
    import prompt.integrations.common: findFile;
    import storage: store, Prop, storeAs;

    import std.path: baseName;
    import std.array: Appender;

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
