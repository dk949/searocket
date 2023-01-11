module prompt.integrations.common;
import std.file;
import std.path;


nothrow
string getCwd() {
    import core.sys.posix.unistd: getcwd;
    import core.stdc.errno: errno, ERANGE;
    import std.exception: assumeUnique;
    auto buf = new char[1024];
    while(getcwd(buf.ptr, buf.length) == null)
        if (errno == ERANGE)
            // Note: could GC.free() the buffer, but it probably doesn't matter since paths don't get that long
            buf = new char[buf.length * 2];
        else
            return null;

    return buf.assumeUnique; // it is unique
}

auto findFile(alias Fn)() {
    alias Ret = typeof(Fn(declval!DirEntry));
    auto dir = getCwd;
    if(dir is null) return Ret.init;
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
