module configutils;

import std.traits: EnumMembers;

version (d) {
    import config: D_COMPILER_ORDER;
    import std.algorithm: all;
}

enum NodeDetectVersion {
    No,
    Yes,
    IfNoNvmrc,
}

enum PythonDetectVersion {
    No,
    Yes,
    IfNoVenv,
}

enum RubyDetectVersion {
    No,
    Yes,
    IfNoGemfile,
}

enum RustDetectVersion {
    No,
    Yes,
    IfNoConfigToml,
}

enum HaskellDetectVersion {
    No,
    Yes,
    IfNoStackYaml,
}

enum DDetectVersion {
    No,
    Yes,
    IfNoPS1,
}

enum ElmDetectVersion {
    No,
    Yes,
    IfNoElmJson,

}

enum GoDetectVersion {
    No,
    Yes,
    IfNoGoMod,
}

enum UsrShow {
    Yes,
    RemoteOnly,
}

enum BatteryShow {
    No,
    Yes,
    Low,
}

/// Use nerd-font dev icons for languages?
enum LanguageIcons {
    No,
    Emoji,
    Yes,
}

string iconSelector(string[[EnumMembers!LanguageIcons].length] icons) {
    return icons[cast(size_t) getFromFile!("use_icons")];
}

auto getFromFile(alias file)() {
    return mixin(import(file));
}

version (d) {

    static assert(D_COMPILER_ORDER.all!(c => c == "ldc" || c == "dmd" || c == "gdc"), "Unsupported Dlang compiler");
}

private
template VersionError(string ver) {
    mixin(
        `version (` ~ ver ~ `) { debug {} else static assert(false, "` ~ ver ~ ` not yet implemented"); }`);
}

mixin VersionError!("battery");
mixin VersionError!("docker");
mixin VersionError!("haskell");
mixin VersionError!("java");
mixin VersionError!("julia");
mixin VersionError!("php");
mixin VersionError!("ruby");
mixin VersionError!("rust");
mixin VersionError!("swift");
mixin VersionError!("xcode");
