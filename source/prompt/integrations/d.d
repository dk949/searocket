module prompt.integrations.d;
version (d) {
    import prompt.integrations.common;
    import storage;
    import common;
    import config;

    import std.algorithm;
    import std.typecons;
    import std.array;
    import std.path;
    import std.process;

    void checkD() {

        final switch (D_DETECT_VERSION) {
            case DDetectVersion.IfNoPS1:
                if (const ver = detectVersionPS1) {
                    store[Prop.InDProject] = ver;
                    break;
                }
                if (!findFile!(d => d.name.baseName == "dub.json" || d.name.baseName == "dub.sdl")) {
                    store[Prop.InDProject] = "";
                    return;
                }
                goto case;
            case DDetectVersion.Yes:
                if (const ver = detectVersion) {
                    store[Prop.InDProject] = ver;
                    break;
                }
                goto case;
            case DDetectVersion.No:
                store[Prop.InDProject] = "D";
                break;
        }
    }

    void buildD(alias start)(ref Appender!string a) {
        const dversion = store[Prop.InDProject];
        if (dversion != "") {
            start;
            a.put(D_COLOR);
            if (dversion == "D")
                a.put(D_SYMBOL);
            else
                a.append(D_SYMBOL, "@", dversion);
        }

    }

    private string detectVersionPS1() {
        const ps1 = environment.get("PS1");
        if (ps1 && ps1.length > 4) {
            // TODO: not guaranteed to work if some other environment loads after D
            //       and puts something else atthe beginning of PS1.
            if (ps1[0 .. 4] == "(dmd"
                || ps1[0 .. 4] == "(ldc"
                || ps1[0 .. 4] == "(gdc"
                ) {
                const end = countUntil(ps1[1 .. $], ')');
                if (end != -1)
                    return ps1[1 .. end + 1];
            }
        }
        return null;
    }

    private string detectVersion() {
        return detectVersionImpl!(D_COMPILER_ORDER, versionString);
    }

    private string detectVersionImpl(string[] compilerOrder, alias getVer)() {
        foreach (comp; compilerOrder) {
            final switch (comp) {
                case "ldc":
                    auto v = getVer!("ldc2");
                    if (!v)
                        continue;
                    v = v.splitter('\n')
                        .front;
                    const lb = countUntil(v, '(');
                    const rb = countUntil(v, ')');
                    return "ldc-" ~ v[lb + 1 .. rb];
                case "dmd":
                    auto v = getVer!("dmd");
                    if (!v)
                        continue;
                    v = v.splitter('\n')
                        .front
                        .splitter(' ')
                        .back;
                    return "dmd-" ~ v[1 .. $];
                case "gdc":
                    auto v = getVer!("gdc");
                    if (!v)
                        continue;
                    v = v.splitter('\n')
                        .front;
                    const start = v.countUntil(')') + 2;
                    return "gdc-" ~ v[start .. $];
            }
        }
        return null;
    }

    unittest {
        import std.stdio;

        string ldcVrsion(string c)() {
            return `LDC - the LLVM D compiler (1.30.0):
  based on DMD v2.100.1 and LLVM 14.0.3
  built with LDC - the LLVM D compiler (1.30.0)
  Default target: x86_64-unknown-linux-gnu
  Host CPU: skylake
  http://dlang.org - http://wiki.dlang.org/LDC

  Registered Targets:
    aarch64    - AArch64 (little endian)
    aarch64_32 - AArch64 (little endian ILP32)
    aarch64_be - AArch64 (big endian)
    amdgcn     - AMD GCN GPUs
    arm        - ARM
    arm64      - ARM64 (little endian)
    arm64_32   - ARM64 (little endian ILP32)
    armeb      - ARM (big endian)
    avr        - Atmel AVR Microcontroller
    bpf        - BPF (host endian)
    bpfeb      - BPF (big endian)
    bpfel      - BPF (little endian)
    hexagon    - Hexagon
    lanai      - Lanai
    mips       - MIPS (32-bit big endian)
    mips64     - MIPS (64-bit big endian)
    mips64el   - MIPS (64-bit little endian)
    mipsel     - MIPS (32-bit little endian)
    msp430     - MSP430 [experimental]
    nvptx      - NVIDIA PTX 32-bit
    nvptx64    - NVIDIA PTX 64-bit
    ppc32      - PowerPC 32
    ppc32le    - PowerPC 32 LE
    ppc64      - PowerPC 64
    ppc64le    - PowerPC 64 LE
    r600       - AMD GPUs HD2XXX-HD6XXX
    riscv32    - 32-bit RISC-V
    riscv64    - 64-bit RISC-V
    sparc      - Sparc
    sparcel    - Sparc LE
    sparcv9    - Sparc V9
    systemz    - SystemZ
    thumb      - Thumb
    thumbeb    - Thumb (big endian)
    ve         - VE
    wasm32     - WebAssembly 32-bit
    wasm64     - WebAssembly 64-bit
    x86        - 32-bit X86: Pentium-Pro and above
    x86-64     - 64-bit X86: EM64T and AMD64
    xcore      - XCore
`;
        }

        const res = detectVersionImpl!(["ldc"], ldcVrsion)();
        assert(res == "ldc-1.30.0");
    }

    unittest {
        import std.stdio;

        string dmdVersion(string c)() {
            return `DMD64 D Compiler v2.100.2
Copyright (C) 1999-2022 by The D Language Foundation, All Rights Reserved written by Walter Bright
`;
        }

        const res = detectVersionImpl!(["dmd"], dmdVersion)();
        assert(res == "dmd-2.100.2");
    }
}

unittest {
    import std.stdio;

    string gdcVrsion(string c)() {
        return `gdc (gdcproject.org 20161225-v2.068.2_gcc4.8) 4.8.5
Copyright (C) 2015 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

`;
    }

    const res = detectVersionImpl!(["gdc"], gdcVrsion)();
    assert(res == "gdc-4.8.5");
}
