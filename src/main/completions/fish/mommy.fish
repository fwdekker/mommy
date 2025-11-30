## Helper functions
# Extracts the non-option commands from `$argv` and writes to stdout.
# For example, given `mommy -c ./config.sh apt update -f`, writes `apt update -f`.
function extract_command
    set --erase argv[1]

    set --local is_option_argument 0
    for arg in $argv
        if test $is_option_argument -eq 1
            set --erase argv[1]
            set is_option_argument 0
            continue
        end

        switch $arg
            case '-c' '-e' '-s'  # Do not include long options here!
                set --erase argv[1]
                set is_option_argument 1
            case '-*'
                set --erase argv[1]
            case '*'
                echo $argv
                return 0
        end
    end

    return 0
end

# Extract the args, excluding the arg that the user is currently writing.
function get_args
    set --local tokens (commandline -opc)

    extract_command $tokens
end

# Extract the args, including the arg that the user is currently writing.
function get_args_with_token
    set --local tokens (commandline -opc) (commandline -ct)

    extract_command $tokens
end


## Completions
set --local opt_help    "--short-option h --long-option help"
set --local opt_version "--short-option v --long-option version"
set --local opt_eval    "--short-option e --long-option eval"
set --local opt_status  "--short-option s --long-option status"

complete --command mommy --no-files  # Disabled by default, but re-enabled for specific cases below

# Help/version
complete --command mommy --short-option h --long-option help \
    --description "Show manual" \
    --condition "__fish_is_first_arg"
complete --command mommy --short-option v --long-option version \
    --description "Show version" \
    --condition "__fish_is_first_arg"

# Config
complete --command mommy --short-option c --long-option config \
    --require-parameter --force-files \
    --description "Configuration file" \
    --condition "not __fish_seen_argument $opt_help $opt_version"\
    --condition "test -z (get_args)"
complete --command mommy --short-option d --long-option global-config-dirs \
    --require-parameter \
    --arguments "(__fish_complete_directories)" \
    --description "Colon-separated global config file dirs" \
    --condition "not __fish_seen_argument $opt_help $opt_version"\
    --condition "test -z (get_args)"

# Misc
complete --command mommy --short-option 1 \
    --description "Write to stdout" \
    --condition "not __fish_seen_argument $opt_help $opt_version" \
    --condition "test -z (get_args)"
complete --command mommy --long-option rename \
    --require-parameter \
    --description "Change executable name" \
    --condition "not __fish_seen_argument $opt_help $opt_version" \
    --condition "test -z (get_args)"
complete --command mommy --long-option remove-rename \
    --require-parameter \
    --description "Remove rename and symlinks" \
    --condition "not __fish_seen_argument $opt_help $opt_version" \
    --condition "test -z (get_args)"

# Usage
complete --command mommy \
    # `complete --do-complete` requires one argument, so must be wrapped in quotes.
    # Fish <3.4.0 cannot do `$(...)`, so workaround is to assign to temporary variable.
    --keep-order \
    --arguments "(set --local command (get_args_with_token); complete --do-complete \"\$command\")" \
    --condition "test -n (get_args_with_token); or not __fish_seen_argument $opt_help $opt_version $opt_eval $opt_status"
complete --command mommy --short-option e --long-option eval \
    --require-parameter \
    --description "Evaluate string" \
    --condition "not __fish_seen_argument $opt_help $opt_version $opt_status" \
    --condition "test -z (get_args)"
complete --command mommy --short-option s --long-option status \
    --require-parameter --no-files \
    --description "Exit code" \
    --arguments "(echo 0\tSuccess\n1\tError)" \
    --condition "not __fish_seen_argument $opt_help $opt_version $opt_eval" \
    --condition "test -z (get_args)"
