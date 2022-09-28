module configutils;

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
enum DDetectVersion {
    No,
    Yes,
    IfNoPS1,
}

import config: D_COMPILER_ORDER;
import std.algorithm;

static assert(D_COMPILER_ORDER.all!(c => c == "ldc" || c == "dmd" || c == "gdc"), "Unsupported Dlang compiler");
