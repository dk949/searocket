import std.process;
import std.stdio;
import std.path;
import std.file;
import std.string;

immutable template_ = "
export SEAROCKET_VERSION='%s'

___searocket_preCommand (){
    PROMPT=$(searocket preCommand prompt)
    RPROMPT=$(searocket preCommand rprompt)
}

___searocket_preExec (){
    searocket preExec prompt
}

___searocket_onExit (){
    searocket onExit prompt
}


___searocket_setup() {
    autoload -Uz add-zsh-hook

    add-zsh-hook precmd ___searocket_preCommand
    add-zsh-hook preexec ___searocket_preExec
    add-zsh-hook zshexit ___searocket_onExit

    VIRTUAL_ENV_DISABLE_PROMPT=true

    ___searocket_preExec
}

___searocket_setup

";

int main(string[] args) {
    if(args.length != 2) {
        stderr.writeln("Expected 1 argument got ", cast(int)args.length - 1);
        return -1;
    }
    immutable filename = args[1];
    immutable cwd = __FILE_FULL_PATH__.dirName;

    immutable desc = std.process.execute(["git", "-C", cwd, "describe"]);

    if(desc.status) {
        stderr.writefln("`git describe` failed with exit code %d and message:\n%s", desc.status, desc.output);
        return desc.status;
    }
    try {
        filename.dirName.mkdirRecurse();
        auto fp = File(filename, "w");
        fp.writef(template_, desc.output.strip());
    } catch(Exception e) {
        stderr.writeln("could not open or write to file: ", e.message);
        return -2;
    }

    return 0;
}
