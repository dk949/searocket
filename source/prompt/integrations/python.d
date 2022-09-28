module prompt.integrations.python;
version (python) {

    import prompt.integrations.common;
    import common;
    import storage;
    import config;

    import std.algorithm;
    import std.array;
    import std.file;
    import std.path;
    import std.process;

    void checkPython() {
        if (const venv = environment.get("VIRTUAL_ENV")) {
            auto pyenv = buildPath(venv, "pyvenv.cfg");
            if (pyenv.exists) {
                auto cfg = readText(pyenv);
                store[Prop.InPyEnv] = cfg
                    .splitter(EOL)
                    .filter!(line => startsWith(line, "version"))
                    .front
                    .splitter(' ')
                    .array[2];
            }
        } else
            store[Prop.InPyEnv] = findFile!(d =>
                    d.name.baseName == "requirements.txt"
                    || d.name.baseName == "Pipfile"
                    || d.name.baseName == "pyproject.toml"
            ) ? "python" : "";
    }

    void buildPython(alias start)(ref Appender!string a) {
        const venv = store[Prop.InPyEnv];
        if (venv != "") {
            start;
            a.put(PYTHON_COLOR);
            if (venv == "python")
                a.append(PYTHON_SYMBOL);
            else
                a.append(PYTHON_SYMBOL,"@", venv);
        }
    }
}
