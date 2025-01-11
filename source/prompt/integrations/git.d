module prompt.integrations.git;

version (git) {

    import common: append;
    import config: GIT_ADDED_CHAR,
        GIT_AHEAD_CHAR,
        GIT_BEHIND_CHAR,
        GIT_CHAR,
        GIT_COLOR,
        GIT_COMMIT_CHAR,
        GIT_DELETED_CHAR,
        GIT_DETACHED_COLOR,
        GIT_DIVERGED_CHAR,
        GIT_MODIFIED_CHAR,
        GIT_RENAMED_CHAR,
        GIT_STASHED_CHAR,
        GIT_STATUS_COLOR,
        GIT_TAG_CHAR,
        GIT_UNMERGED_CHAR,
        GIT_UNTRACKED_CHAR;
    import prompt.integrations.common: findFile;
    import storage: store, storeAs, Prop;

    import std.algorithm: any;
    import std.process: execute;
    import std.string: stripRight;
    import std.regex: ctRegex, matchFirst;
    import std.functional: memoize;
    import std.conv: to, text;
    import std.array: Appender;

    private struct GitHead {
        enum State {
            None,
            Branch,
            Tag,
            Sha,
        }

        State state;
        string value;
    }

    private struct GitStatus {
        enum RemoteState {
            None,
            Ahead,
            Behind,
            Diverged,
        }

        bool added;
        bool modified;
        bool renamed;
        bool deleted;
        bool untracked;
        RemoteState remoteState;
        bool unmerged;
        bool stashed;

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

    private GitStatus getGitStatus() {
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
            const a = git("rev-list", "--count", gitHead.value ~ "@{upstream}..HEAD");
            if (a)
                return a.to!int;
            else
                return 0;
        }();

        const behind = {
            const b = git("rev-list", "--count", "HEAD.." ~ gitHead.value ~ "@{upstream}");
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

    private void buildGitHead(ref Appender!string a) {
        const branch = gitHead;
        final switch (branch.state) {
            case GitHead.State.None:
                return;
            case GitHead.State.Branch:
                a.append(GIT_COLOR, GIT_CHAR, branch.value);
                return;
            case GitHead.State.Tag:
                a.append(GIT_DETACHED_COLOR, GIT_TAG_CHAR, branch.value);
                return;
            case GitHead.State.Sha:
                a.append(GIT_DETACHED_COLOR, GIT_COMMIT_CHAR, branch.value);
                return;
        }
    }

    void checkGit() {
        store[Prop.InGitRepo] = findFile(".git").storeAs!bool;
    }

    void buildGit(alias start)(ref Appender!string a) {
        if (!(store[Prop.InGitRepo].to!int))
            return;

        buildGitHead(a);

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

    alias gitHead = memoize!getGitHead;

private:

    string git(S...)(S cmd) {
        const res = execute(["git", cmd]);
        if (res.status != 0)
            return null;
        return res.output.stripRight;
    }

    GitHead getGitHead() {
        const branch_or_head = git("rev-parse", "--abbrev-ref", "HEAD");
        if (branch_or_head == null)
            return GitHead(GitHead.State.None, null);
        else if (branch_or_head == "HEAD") {
            if (const tag_name = git("describe", "--exact-match", "--tags"))
                return GitHead(GitHead.State.Tag, tag_name);
            else
                return GitHead(GitHead.State.Sha, git("rev-parse", "--short", "HEAD"));
        } else
            return GitHead(GitHead.State.Branch, branch_or_head);
    }
}
