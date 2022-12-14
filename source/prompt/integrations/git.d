module prompt.integrations.git;
import config;
version (git) {

    import common;
    import prompt.colors;
    import prompt.integrations.common;
    import storage;

    import std.bitmanip;
    import std.algorithm;
    import std.process;
    import std.string;
    import std.regex;
    import std.functional;
    import std.conv;
    import std.stdio;
    import std.array;

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
        string toString() const {
            return text("GitStatus(", '\n',
                "\tadded = ", added, '\n',
                "\tmodified = ", modified, '\n',
                "\trenamed = ", renamed, '\n',
                "\tdeleted = ", deleted, '\n',
                "\tuntracked = ", untracked, '\n',
                "\tremoteState = ", remoteState, '\n',
                "\tunmerged = ", unmerged, '\n',
                "\tstashed = ", stashed, '\n',
                ')'
            );
        }
    }

    GitStatus getGitStatus() {
        /*
        The expressions used to pare git status are taken directly from
        spaceship prompt, and hence are licensed by them under the MIT license
        (see README for more detail).
    */
        static immutable untrackedRE = ctRegex!(`^\?\?`, "m");
        static immutable stagedREs = [
            ctRegex!(`^A[ MDAU] `, "m"),
            ctRegex!(`^M[ MD] `, "m"),
            ctRegex!(`^UA`, "m"),
        ];
        static immutable modifiedRE = ctRegex!(`^[ MARC]M `, "m");
        static immutable renamedRE = ctRegex!(`^R[ MD] `, "m");
        static immutable deletedREs = [
            ctRegex!(`^[MARCDU ]D `, "m"),
            ctRegex!(`^D[ UM] `, "m"),
        ];
        static immutable unmergedREs = [
            ctRegex!(`^U[UDA] `, "m"),
            ctRegex!(`^AA `, "m"),
            ctRegex!(`^DD `, "m"),
            ctRegex!(`^[DA]U `, "m"),
        ];

        GitStatus output;
        const s = git("status", "--porcelain");

        // Check for untracked files
        output.untracked = !!s.matchFirst(untrackedRE);

        // Check for staged files
        output.added = any!(r => s.matchFirst(r))(stagedREs);

        // Check for modified files
        output.modified = !!s.matchFirst(modifiedRE);

        // Check for renamed files
        output.renamed = !!s.matchFirst(renamedRE);

        // Check for deleted files
        output.deleted = any!(r => s.matchFirst(r))(deletedREs);

        // Check for unmerged files
        output.unmerged = any!(r => s.matchFirst(r))(unmergedREs);

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

    void checkGit() {
        store[Prop.InGitRepo] = findFile(".git").storeAs!bool;
    }

    void buildGit(alias start)(ref Appender!string a) {
        if (!(store[Prop.InGitRepo].to!int))
            return;

        const branch = gitBranch;

        if (branch)
            a.append(GIT_COLOR, GIT_CHAR, branch);
        const status = getGitStatus();
        if (status == status.init)
            return;

        a.append(GIT_STATUS_COLOR, " [");
        scope (exit)
            a.put(']');

        if (status.added)
            a.put(GIT_ADDED_CHAR);
        if (status.modified)
            a.put(GIT_MODIFIED_CHAR);
        if (status.renamed)
            a.put(GIT_RENAMED_CHAR);
        if (status.deleted)
            a.put(GIT_DELETED_CHAR);
        if (status.untracked)
            a.put(GIT_UNTRACKED_CHAR);
        if (status.unmerged)
            a.put(GIT_UNMERGED_CHAR);
        if (status.stashed)
            a.put(GIT_STASHED_CHAR);

        switch (status.remoteState) {
            case GitStatus.RemoteState.Ahead:
                a.put(GIT_AHEAD_CHAR);
                break;
            case GitStatus.RemoteState.Behind:
                a.put(GIT_BEHIND_CHAR);
                break;
            case GitStatus.RemoteState.Diverged:
                a.put(GIT_DIVERGED_CHAR);
                break;
            default:
                break;
        }
    }

    alias gitBranch = memoize!getGitBranch;

private:

    string git(S...)(S cmd) {
        import std.stdio;

        const res = execute(["git", cmd]);
        if (res.status != 0)
            return null;
        return res.output.stripRight;
    }

    string getGitBranch() {
        return git("branch", "--show-current");
    }
}
