module prompt.mainprompt;

import prompt.integrations;
import prompt.integrations.git;
import prompt.colors;

import common;
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

enum Mode {
    Prompt = "prompt",
    Rprompt = "rprompt",
}

enum Hook {
    PreCommand = "preCommand",
    PreExec = "preExec",
    OnExit = "onExit",
}

string mainPrompt() {
    auto a = appender!string;
    buildEnv(a);

    // User name
    a.append("%(!.", Red, ".", Yellow, ")%n ");

    // Directory name
    a.append(Cyan, "%4~");

    // background process running
    a.append("%(1j. ", Blue, "✦.)");

    // Git
    version (git)
        buildGit!(null)(a);

    // Last command succeeded?
    if (store[Prop.Exec].to!int)
        a.append("%(0?.", Green, ".", Red, " %?)");
    else
        a.append(Green);

    // prompt charcter
    a.append(" ❯ ", Default);

    return a.data;
}

string mainRprompt() {
    auto oldTime = {
        if (const o = store[Prop.StartTime])
            return dur!"hnsecs"(o.to!long);
        else
            return Duration.zero;
    }();
    long newTime = Clock.currStdTime;
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
