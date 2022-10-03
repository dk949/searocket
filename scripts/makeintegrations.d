#!/usr/bin/env dub
/+dub.json:
{
    "name": "makeintegrations"
}
+/

import std.file;
import std.path;
import std.stdio;
import std.string;
import std.array;

void addToFile(string name, ref Appender!string a) {
    a.put("version (");
    a.put(name);
    a.put(") import prompt.integrations.");
    a.put(name);
    a.put(";\n");
}

void addToCheck(string name, ref Appender!string a) {
    a.put("    version (");
    a.put(name);
    a.put(") {
        check");
    a.put(name[0].toUpper);
    a.put(name[1 .. $]);
    a.put("();
    }\n");
}

void addToBuild(string name, ref Appender!string a) {
    a.put("    version (");
    a.put(name);
    a.put(") {
        build");
    a.put(name[0].toUpper);
    a.put(name[1 .. $]);
    a.put("!(start)(a);
    }\n");
}

int main(string[] args) {
    if (args.length != 3) {
        stderr.writeln("Expeted 2 argument got ", args.length);
        return 1;
    }

    const dir = args[1];
    const dest = args[2];

    if (!(dir.exists && dir.isDir)) {
        stderr.writeln(dir, " is not a directory");
        return 1;
    }

    if (dest.exists && !dest.isFile) {
        stderr.writeln(dest, " exists and is not a file");
        return 1;
    }

    auto file = appender!string;
    auto checkEnv = appender!string;
    auto buildEnv = appender!string;

    file.put(`
/*
THIS FILE IS AUTO GENERATED. DO NOT EDIT BY HAND

See scripts/makeintegrations.d
*/

module prompt.integrations;

import common;
import config;
import prompt.colors;

import std.array;

`);

    checkEnv.put(`
void checkEnv() {
`);

    buildEnv.put(`
void buildEnv(ref Appender!string a) {
    bool inEnv = false;
    int envcount = 0;
    char end = ' ';
    void start() {
        envcount++;
        if (envcount >= 3)
            end = '\n';
        if (!inEnv) {
            a.append(INTEGRATION_COLOR, INTEGRATION_START_CHAR);
            inEnv = true;
        } else {
            a.append(INTEGRATION_COLOR, ", ");
        }
    }
    scope(exit)
        if(inEnv)
            a.append(INTEGRATION_COLOR, INTEGRATION_END_CHAR, end);

`);

    foreach (ent; dirEntries(dir, SpanMode.shallow)) {
        auto name = ent.name.baseName;
        if (name == "package.d" || name == "common.d" || name == "git.d")
            continue;

        if (!(name.length >= 3 && endsWith(name, ".d"))) {
            stderr.writeln("expected only D module files, found ", name);
            return 1;
        }
        name.length -= 2;
        name.addToFile(file);
        name.addToCheck(checkEnv);
        name.addToBuild(buildEnv);

    }
    checkEnv.put('}');
    buildEnv.put('}');

    file.put(checkEnv.data);
    file.put(buildEnv.data);

    auto f = File(dest, "w");
    f.rawWrite(file.data);
    return 0;
}
