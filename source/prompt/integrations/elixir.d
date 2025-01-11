module prompt.integrations.elixir;

version (elixir) {
    import common: append, EOL;
    import prompt.integrations.common: findFile, versionString;
    import storage: store, Prop, storeAs;
    import config: ELIXIR_DETECT_VERSION, ELIXIR_SYMBOL, ELIXIR_COLOR;

    import std.array: Appender;
    import std.algorithm.searching: find, countUntil;

    void checkElixir() {
        if (!findFile("mix.exs")) {
            store[Prop.InElixirProject] = "";
            return;
        }
        static if (ELIXIR_DETECT_VERSION) {
            if (const ver = versionString!("elixir")) {
                store[Prop.InElixirProject] = ver.extractVersion;
                return;
            }
        }
        store[Prop.InElixirProject] = "elixir";
    }

    void buildElixir(alias start)(ref Appender!string a) {
        const ver = store[Prop.InElixirProject];
        if (ver != "") {
            start;
            a.put(ELIXIR_COLOR);
            if (ver == "elixir")
                a.put(ELIXIR_SYMBOL);
            else
                a.append(ELIXIR_SYMBOL, " @", ver);
        }

    }

    private string extractVersion(string ver) {
        immutable elixir = "Elixir";
        auto ver_line = ver.find(elixir)[elixir.length .. $];
        if (ver_line.length <= 1)
            return "elixir";
        if (ver_line[0] != ' ')
            return "elixir";
        ver_line = ver_line[1 .. $];
        const end = ver_line.countUntil(' ');
        if (end == -1)
            return "elixir";
        return ver_line[0 .. end];
    }

    unittest {
        immutable ver_str = `Erlang/OTP 27 [erts-15.1.3] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Elixir 1.18.1 (compiled with Erlang/OTP 27)`;
        const extracted = extractVersion(ver_str);
        assert(extracted == "1.18.1", "Expected '1.18.1`, got " ~ extracted);
    }
}
