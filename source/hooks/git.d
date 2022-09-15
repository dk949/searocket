module hooks.git;
import std.bitmanip;
import std.process;
import std.string;
import std.regex;
import std.functional;
import std.conv;
import std.stdio;
import common;


static assert(GitStatus.sizeof == 2);
struct GitStatus {
    enum RemoteState {
        None,
        Ahead,
        Behind,
        Diverged,
    }

    mixin(
        bitfields!(
            bool, "added", 1,
            bool, "modified", 1,
            bool, "renamed", 1,
            bool, "deleted", 1,

            bool, "untracked", 1,

            RemoteState, "remoteState", 2,

            bool, "unmerged", 1,

            bool, "stashed", 1,

            int, "", 7
    )
    );
}

// TODO
GitStatus getGitStatus() {
    GitStatus output;
    const s = git("status", "--porcelain");
    static immutable untrackedRE = ctRegex!(`^??`);
    static immutable addedRE = ctRegex!(`^(?:(?:A[ MDAU] )|(?:M[ MD] ))|(?:UA)`);
    static immutable modifiedRE = ctRegex!(`^[ MARC]M `);
    static immutable renamedRE = ctRegex!(`^R[ MD] `);
    static immutable deletedRE = ctRegex!(`^(?:[MARCDU ]D )|(?:D[ UM] )`);
    static immutable unmergedRE = ctRegex!(`(?:(?:(?:U[UDA] )|(?:AA ))|(?:DD ))|(?:[DA]U )`);

    // Check for untracked files
    output.untracked = !!s.matchFirst(untrackedRE);

    // Check for staged files
    output.added = !!s.matchFirst(addedRE);

    // Check for modified files
    output.modified = !!s.matchFirst(modifiedRE);

    // Check for renamed files
    output.renamed = !!s.matchFirst(renamedRE);

    // Check for deleted files
    output.deleted = !!s.matchFirst(deletedRE);

    // Check for unmerged files
    output.unmerged = !!s.matchFirst(unmergedRE);

    //Check for stashes
    output.stashed = !!git("rev-parse", "--verify", "refs/stash");

    // Ahead, behind or diverged
    const ahead = {
        const a = git("rev-list", "--count", gitBranch ~ "@{upstream}..HEAD");
        if (a)
            return a.to!int;
        else
            return 0;
    }();

    const behind = {
        const b = git("rev-list", "--count", "HEAD.." ~ gitBranch ~ "@{upstream}");
        if (b)
            return b.to!int;
        else
            return 0;
    }();

    if (ahead && behind)
        output.remoteState = GitStatus.RemoteState.Diverged;
    else if (ahead)
        output.remoteState = GitStatus.RemoteState.Ahead;
    else if (behind)
        output.remoteState = GitStatus.RemoteState.Behind;

    return output;
}

alias gitBranch = memoize!getGitBranch;

private:

string git(S...)(S cmd) {
    import std.stdio;

    const res = execute(["git", cmd]);
    if (res.status != 0)
        return null;
    return res.output.strip;
}

string getGitBranch() {
    return git("branch", "--show-current");
}
