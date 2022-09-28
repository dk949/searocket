module prompt.integrations.common;
import std.file;
import std.path;

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

string versionString(string exe, string param = "--version")() {
    import std.process;
    import std.string;
    import common;
    try {
        const e = execute([exe, param]);
        if (e.status != 0)
            dbgthrow!Exception("could not get " ~ exe ~ " version");
        return e.output.stripRight;
    } catch (ProcessException e)
        return null;
}

T declval(T)();
