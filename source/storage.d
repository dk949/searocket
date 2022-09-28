/// Abstraction over persistent storage. Should allow storage method to change in the future
module storage;

import common;

import std.file;
import std.stdio;
import std.array;
import std.range;
import std.traits;
import std.conv;

private enum FILE_NAME = "searocket.data";

enum Prop {

    Exec,
    StartTime,

    InBunProject,
    InDProject,
    InDockerProject,
    InElixirProject,
    InElmProject,
    InGitRepo,
    InGoProject,
    InHaskellProject,
    InJavaProject,
    InJuliaProject,
    InNodeProject,
    InPhpProject,
    InPyEnv,
    InRubyProject,
    InRustProject,
}

Storage store;

static this() {
    store = Storage.get;
}

class Storage {
    private string[Prop.max + 1] data;
    private File m_handle;

    string name() const {
        return m_handle.name;
    }

    void close() {
        m_handle.close;
    }

    this(File handle) {
        m_handle = handle;
        for (size_t i = 0; i <= Prop.max; i++) {
            data[i] = handle.readln;
            if (data[i])
                data[i] = data[i][0 .. ($ - EOL.length)];
        }
    }

    string opIndexAssign(string val, Prop prop) {
        debug if (!m_handle.isOpen)
            dbgthrow!Exception("accessing storage after it was closed");

        data[prop] = val;
        return data[prop];
    }

    string opIndex(Prop prop) const {
        debug if (!m_handle.isOpen)
            dbgthrow!Exception("accessing storage after it was closed");
        return data[prop];
    }

    ~this() {
        m_handle.rewind;
        foreach (line; data)
            m_handle.writeln(line);
    }

    private static Storage instance = null;
    static Storage get() {
        if (!instance)
            instance = new Storage({
                auto f = tempDir ~ "/" ~ text(parentProcess) ~ FILE_NAME;
                if (!exists(f))
                    makeFile(f);
                return File(f, "r+");
            }()
            );

        return instance;
    }

    private static void makeFile(string f) {
        auto file = File(f, "w");
        static foreach (prop; only(EnumMembers!Prop)) {
            // using a final switch to make ure if a field is added to Prop, it gets populated here
            final switch (prop) {
                case Prop.StartTime:
                case Prop.Exec:
                case Prop.InGitRepo:
                case Prop.InRubyProject:
                case Prop.InDockerProject:
                case Prop.InElixirProject:
                case Prop.InHaskellProject:
                case Prop.InJavaProject:
                case Prop.InJuliaProject:
                case Prop.InPhpProject:
                case Prop.InRustProject:
                    file.writeln(0);
                    break;
                case Prop.InGoProject:
                case Prop.InBunProject:
                case Prop.InDProject:
                case Prop.InElmProject:
                case Prop.InNodeProject:
                case Prop.InPyEnv:
                    file.writeln("");
                    break;
            }
        }
    }

}

private int parentProcess() {
    version (Posix) {
        import core.sys.posix.unistd;

        return getppid();
    }
    // WARNING: UNTESTED CODE AHEAD
    // basically I don't have a windows computer, but insternet says this should be about right(?)
    // https://gist.github.com/mattn/253013/d47b90159cf8ffa4d92448614b748aa1d235ebe4
    version (Windows) {
        import core.sys.windows.windows;
        import core.sys.windows.tlhelp32;
        import core.stdc.string;

        PROCESSENTRY32 pe32;
        DWORD ppid = 0;
        const DWORD pid = GetCurrentProcessId();
        HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

        if (hSnapshot == INVALID_HANDLE_VALUE)
            goto cleanup;

        memset(&pe32, 0, pe32.sizeof);
        pe32.dwSize = pe32.sizeof;
        if (hSnapshot.Process32First(&pe32))
            goto cleanup;

        do
            if (pe32.th32ParentProcessID == pid) {
                ppid = pe32.th32ParentProcessID;
                break;
            }
        while (hSnapshot.Process32Next(&pe32));

    cleanup:
        if (hSnapshot != INVALID_HANDLE_VALUE)
            hSnapshot.CloseHandle();

        return ppid;

    }

}

string storeAs(Ret : string, Arg)(auto ref const Arg thing) {
    import std.conv;

    return thing.text;
}

string storeAs(Ret : bool, Arg)(auto ref const Arg thing) {
    import std.conv;

    return text(cast(int)(!!thing));
}

T storeAs(T, Arg)(auto ref const Arg) {
    static assert(false, "Can only stire as bool or string");
}
