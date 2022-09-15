module checkenv;

import common;
import mainprompt;

import storage;

import std.array;
import std.path;
import std.file;
import std.process;
import std.stdio;
import std.algorithm;
import std.traits;
import std.string;

public:
void checkEnv() {
    version (git)
        checkGit();
    version (D)
        checkD();
    version (python)
        checkPython();
    version (nodejs)
        checkNodejs();
    version (battery)
        checkBattery();
    version (haskell)
        checkHaskell();
    version (rust)
        checkRust();
    version (zig)
        checkZig();
}

private:

version (git) void checkGit() {
    store[Prop.InGitRepo] = cast(int) !!findFile(".git");
}

version (D) void checkD() {
    const ps1 = environment.get("PS1");
    if (ps1 && ps1.length > 4) {
        // TODO: not guaranteed to work if some other environment loads after D
        //       and puts something else atthe beginning of PS1.
        if (ps1[0 .. 4] == "(dmd"
            || ps1[0 .. 4] == "(ldc"
            || ps1[0 .. 4] == "(gdc"
            ) {
            const end = countUntil(ps1[1 .. $], ')');
            if (end != -1) {
                store[Prop.InDProject] = ps1[1 .. end + 1];
                return;
            }
        }
    }
    store[Prop.InDProject] = findFile!(
        d =>
            d.name.baseName == "dub.json"
            || d.name.baseName == "dub.sdl"
    ) ? "D" : "";
}

version (python) void checkPython() {
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
        store[Prop.InPyEnv] = "";
}

version (nodejs) void checkNodejs() {
    string ver = "";
    if (auto nvmrc = findFile(".nvmrc"))
        ver = readText(nvmrc).strip;

    else if (findFile("package.json")) {
        version (nodejsglobalversion)
            ver = nodeGlobalVersion;
        else
            ver = "node";
    }

    store[Prop.InNodeProject] = ver;
}

version (nodejsglobalversion) string nodeGlobalVersion() {
    import std.process;

    const res = execute(["node", "-v"]);
    if (res.status == 0)
        return res.output.strip;
    else
        return null;

}

version (battery) void checkBattery() {
}

version (haskell) void checkHaskell() {
}

version (rust) void checkRust() {
}

version (zig) void checkZig() {
}

auto findFile(alias Fn)() {
    string dir = getcwd;
    string nextDir;
    while ((nextDir = dirName(dir)) != rootName(dir)) {
        foreach (DirEntry d; dirEntries(dir, SpanMode.shallow)) {
            auto res = Fn(d);
            if (res)
                return res;
        }
        dir = nextDir;
    }
    alias Ret = typeof(Fn(declval!DirEntry));
    return Ret.init;
}

string findFile(string name) {
    return findFile!(d => d.name.baseName == name ? d.name : null);
}

T declval(T)();
