module mainprompt;

import common;
import git;
import storage;

import core.time;
import std.algorithm;
import std.array;
import std.conv;
import std.datetime;
import std.file;
import std.math.rounding;
import std.process;
import std.range;
import std.stdio;
import std.traits;

private void append(T, Args...)(ref T a, auto ref Args args)
if (isInstanceOf!(Appender, T)) {
    foreach (arg; args) {
        a.put(arg);
    }
}

enum Mode {
    Prompt = "prompt",
    Rprompt = "rprompt",
}

enum Hook {
    OnDirChange = "onDirChange",
    OnPeriodic = "onPeriodic",
    PreCommand = "preCommand",
    PreExec = "preExec",
    OnExit = "onExit",
}

enum {
    Black = "%F{black}",
    Red = "%F{red}",
    Green = "%F{green}",
    Yellow = "%F{yellow}",
    Blue = "%F{blue}",
    Magenta = "%F{magenta}",
    Cyan = "%F{cyan}",
    White = "%F{white}",
    Default = "%F{default}",
}

string mainPrompt() {
    auto a = appender!string;
    buildEnv(a);
    a.append(Yellow, "%n ", Cyan, "%~%(1j. ", Blue, "✦.)");

    version (git)
        buildGit(a);

    if (store[Prop.Exec].to!int)
        a.append("%(0?.", Green, ".", Red, " %?)");
    else
        a.append(Green);
    a.append(" ❯ ", Default);

    return a.data;
}

string mainRprompt() {
    auto oldTime = {
        const o = store[Prop.StartTime];
        if (o !is null)
            return dur!"hnsecs"(o.to!long);
        else
            return Duration.zero;
    }();
    long newTime = std.datetime.Clock.currStdTime;
    auto took = dur!"hnsecs"(newTime) - oldTime;
    if (took > dur!"seconds"(1))
        return text(Green, "❮", Default, " took: ", Yellow, took.prettyPrint, Default);
    return "";
}

//alias user = memoize!_user;
alias user = _user; // NOTE: IF perf becomes an issue, use the memeoized version

string _user() {
    debug if ("USER" !in environment)
        dbgthrow!Exception("No USER environment variable");
    return environment["USER"];
}

//alias home = memoize!_home;
alias home = _home; // NOTE: IF perf becomes an issue, use the memeoized version

string _home() {
    debug if ("HOME" !in environment)
        dbgthrow!Exception("No home environment variable");
    return environment["HOME"];
}

private float threeDP(float f) {
    return quantize(f, 0.001);
}

private string prettyPrint(Duration time) {
    if (time > dur!"hours"(24)) {
        int days;
        int hours;
        int minutes;
        int seconds;
        time.split!("days", "hours", "minutes", "seconds")(days, hours, minutes, seconds);
        return text(days, " day(s) ", hours, "h ", minutes, "m ", seconds, "s");
    } else if (time > dur!"minutes"(60)) {
        int hours;
        int minutes;
        int seconds;
        time.split!("hours", "minutes", "seconds")(hours, minutes, seconds);
        return text(hours, "h ", minutes, "m ", seconds, "s");
    } else if (time > dur!"seconds"(60)) {
        int minutes;
        int seconds;
        time.split!("minutes", "seconds")(minutes, seconds);
        return text(minutes, "m ", seconds, "s");
    } else if (time >= dur!"seconds"(15)) {
        return text(time.total!"seconds".text, "s");
    } else if (time >= dur!"seconds"(1)) {
        int secs;
        int msecs;
        time.split!("seconds", "msecs")(secs, msecs);
        return (secs + (cast(float) msecs) / 1000).threeDP.text ~ "s";
    } else if (time >= dur!"msecs"(15)) {
        return time.total!"msecs".text ~ "ms";
    } else if (time >= dur!"msecs"(1)) {
        int msecs;
        int usecs;
        time.split!("msecs", "usecs")(msecs, usecs);
        return (msecs + (cast(float) usecs) / 1000).threeDP.text ~ "ms";
    } else {
        return time.total!"usecs".text ~ "μs";
    }
}

private void buildEnv(ref Appender!string a) {
    bool inEnv = false;
    int envcount = 0;
    char end = ' ';
    void start() {
        envcount++;
        if (envcount >= 3)
            end = '\n';
        if (!inEnv) {
            a.append(Blue, '[');
            inEnv = true;
        } else {
            a.put(", ");
        }
    }

    scope (exit)
        if (inEnv)
            a.append(']', end);

    version (D) {
        const dversion = store[Prop.InDProject];
        if (dversion != "") {
            start;
            if (dversion == "D")
                a.put('D');
            else
                a.append("D@", dversion);
        }
    }
    version (python) {
        const venv = store[Prop.InPyEnv];
        if (venv != "") {
            start;
            a.append("🐍@", venv);
        }
    }
    version (nodejs) {
        const node = store[Prop.InNodeProject];
        if (node != "") {
            start;
            if (node == "node")
                a.put("⬢ ");
            else
                a.append("⬢ @", node);
        }
    }
    version (battery) {
    }
    version (haskell) {
    }
    version (rust) {
    }
    version (zig) {
    }
}

version (git) private void buildGit(ref Appender!string a) {
    if (!(store[Prop.InGitRepo].to!int))
        return;
    const branch = gitBranch;
    if (branch)
        a.append(Magenta, "  ", branch);
    const status = getGitStatus();
    if (status == status.init)
        return;

    a.append(Red, " [");
    scope (exit)
        a.put(']');

    if (status.added)
        a.put('+');
    if (status.modified)
        a.put('!');
    if (status.renamed)
        a.put('"');
    if (status.deleted)
        a.put('X');
    if (status.untracked)
        a.put('?');
    if (status.unmerged)
        a.put('=');
    if (status.stashed)
        a.put('$');

    switch (status.remoteState) {
        case GitStatus.RemoteState.Ahead:
            a.put('⇡');
            break;
        case GitStatus.RemoteState.Behind:
            a.put('⇣');
            break;
        case GitStatus.RemoteState.Diverged:
            a.put('⇕');
            break;
        default:
            break;
    }
}
