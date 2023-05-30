module configutils;
import std.traits;

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

string iconSelector(string[[EnumMembers!LanguageIcons].length] icons){
    import config: USE_ICONS;
    return icons[cast(size_t)USE_ICONS];
}

auto getFromFile(alias file)(){
    return mixin(import(file));
}

import config: D_COMPILER_ORDER;
import std.algorithm;

static assert(D_COMPILER_ORDER.all!(c => c == "ldc" || c == "dmd" || c == "gdc"), "Unsupported Dlang compiler");

version (battery) static assert(0, "battery not yet implemented");
version (docker) static assert(0, "docker not yet implemented");
version (elixir) static assert(0, "elixir not yet implemented");
version (haskell) static assert(0, "haskell not yet implemented");
version (java) static assert(0, "java not yet implemented");
version (julia) static assert(0, "julia not yet implemented");
version (php) static assert(0, "php not yet implemented");
version (ruby) static assert(0, "ruby not yet implemented");
version (rust) static assert(0, "rust not yet implemented");
version (swift) static assert(0, "swift not yet implemented");
version (xcode) static assert(0, "xcode not yet implemented");
