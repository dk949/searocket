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
    StartTime,
    Exec,
    InGitRepo,
    InDProject,
    InPyEnv,
    InNodeProject,
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

    this(File handle) {
        m_handle = handle;
        for (size_t i = 0; i <= Prop.max; i++) {
            data[i] = handle.readln;
            if (data[i])
                data[i] = data[i][0 .. ($ - EOL.length)];
        }
    }

    string opIndexAssign(T)(auto ref T val, Prop prop) {
        import std.conv;

        data[prop] = val.text;
        return data[prop];
    }

    string opIndex(Prop prop) const {
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
            final switch (prop) {
                case Prop.StartTime:
                case Prop.Exec:
                case Prop.InGitRepo:
                    file.writeln(0);
                    break;
                case Prop.InDProject:
                case Prop.InPyEnv:
                case Prop.InNodeProject:
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

}
