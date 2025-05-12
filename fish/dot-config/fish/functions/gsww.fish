function gsww
    argparse --min-args 1 --max-args 1 c/create h/help -- $argv
    or return

    if set -ql _flag_help
        echo "Usage: gsww [ -c ] [ -h ] BRANCH" >&2
        return
    end

    set -l target_dir "$(git rev-parse --show-toplevel)/../$(basename $argv[1])"

    if test -d $target_dir && set -ql _flag_create
        # We can't create the branch if the directory already exists.
        echo "error: cannot create directory '$target_dir', already exists."
        return 1
    end

    if set -ql _flag_create
        # Either we create the branch and directory, or ...
        git worktree add -b $argv[1] $target_dir
    else if ! test -d $target_dir
        # ... we only create the directory and switch to the branch, either way ...
        git worktree add $argv[1] $target_dir
    end

    # ... we change directory to it.
    cd $target_dir
end
