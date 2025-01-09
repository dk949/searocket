module prompt.integrations.docker;

// Note: untested
version (docker) {
    import prompt.integrations.common: findFile;
    import storage: store, Prop, storeAs;

    import std.path: baseName;
    import std.array: Appender;

    void checkDocker() {
        store[Prop.InDockerProject] = findFile!(
            // TODO: read https://docs.docker.com/compose/reference/envvars/
            d =>
                d.name.baseName == "Dockerfile"
                || d.name.baseName == "docker-compose.yml"
        ).storeAs!bool;
    }

    void buildDocker(alias start)(ref Appender!string a) {

    }

}
