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
complete --command mommy --no-files  # Disabled by default, but re-enabled for specific cases below

# Help/version/toggle
complete --command mommy --short-option h --long-option help \
    --description "Show manual" \
    --condition "__fish_is_first_arg"
complete --command mommy --short-option v --long-option version \
    --description "Show version" \
    --condition "__fish_is_first_arg"
complete --command mommy --short-option t --long-option toggle \
    --description "Toggle output" \
    --condition "__fish_is_first_arg"

# Config
complete --command mommy --short-option c --long-option config \
    --require-parameter --force-files \
    --description "Configuration file" \
    --condition "not __fish_seen_argument -h --help -v --version -t --toggle"\
    --condition "test -z (get_args)"
complete --command mommy --short-option d --long-option global-config-dirs \
    --require-parameter \
    --arguments "(__fish_complete_directories)" \
    --description "Colon-separated global config file dirs" \
    --condition "not __fish_seen_argument -h --help -v --version -t --toggle"\
    --condition "test -z (get_args)"

# Misc
complete --command mommy --short-option 1 \
    --description "Write to stdout" \
    --condition "not __fish_seen_argument -h --help -v --version -t --toggle -1" \
    --condition "test -z (get_args)"

# Usage
complete --command mommy \
    --keep-order \
    --arguments "(complete --do-complete \"(get_args_with_token)\")" \
    --condition "test -n (get_args_with_token); or not __fish_seen_argument -h --help -v --version -t --toggle -e --eval -p --pipefail -s --status"
complete --command mommy --short-option e --long-option eval \
    --require-parameter \
    --description "Evaluate string" \
    --condition "not __fish_seen_argument -h --help -v --version -t --toggle -e --eval -s --status" \
    --condition "test -z (get_args)"
complete --command mommy --short-option p --long-option pipefail \
    --description "Enable pipefail" \
    --condition "not __fish_seen_argument -h --help -v --version -t --toggle -p --pipefail -s --status" \
    --condition "test -z (get_args)"
complete --command mommy --short-option s --long-option status \
    --require-parameter --no-files \
    --description "Exit code" \
    --arguments "(echo 0\tSuccess\n1\tError)" \
    --condition "not __fish_seen_argument -h --help -v --version -t --toggle -e --eval -p --pipefail -s --status" \
    --condition "test -z (get_args)"
