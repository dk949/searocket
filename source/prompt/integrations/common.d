module prompt.integrations.common;

import common: dbgwarn;

import std.file: dirEntries, DirEntry, SpanMode, getcwd;
import std.path: baseName, dirName, rootName;
import std.process: execute, ProcessException;
import std.string: stripRight;

auto findFile(alias Fn)() {
    alias Ret = typeof(Fn(declval!DirEntry));
    auto dir = getcwd;
    if (dir is null)
        return Ret.init;
    string nextDir;
    while ((nextDir = dirName(dir)) != rootName(dir)) {
        foreach (DirEntry d; dirEntries(dir, SpanMode.shallow)) {
            auto res = Fn(d);
            if (res)
                return res;
        }
        dir = nextDir;
    }
    return Ret.init;
}

string findFile(string name) {
    return findFile!(d => d.name.baseName == name ? d.name : null);
}

string versionString(string exe, string param = "--version")() {
    try {
        const e = execute([exe, param]);
        if (e.status != 0) {
            dbgwarn("could not get " ~ exe ~ " version");
            return null;
        }
        return e.output.stripRight;
    } catch (ProcessException e)
        return null;
}

T declval(T)();
