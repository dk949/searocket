module prompt.integrations.docker;

// Note: untested
version (docker) {
    import prompt.integrations.common;
    import storage;

    import std.path;
    import std.array;

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
