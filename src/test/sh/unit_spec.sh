#!/bin/sh
# shellcheck disable=SC2317 # False positive when using `return` or `exit` inside `Mock`

## Use isolated XDG directories
XDG_CONFIG_DIRS="$MOMMY_TMP_DIR/global/"
export XDG_CONFIG_DIRS

XDG_CONFIG_HOME="$MOMMY_TMP_DIR/user/"
export XDG_CONFIG_HOME

XDG_STATE_HOME="$MOMMY_TMP_DIR/state/"
export XDG_STATE_HOME


## Functions
# Prints the path to configuration directory `$1`
conf_dir() {
    printf "%s\n" "$MOMMY_TMP_DIR/$1"
}

# Prints the path to configuration file `$2` in configuration directory `$1`
conf_file() {
    printf "%s\n" "$MOMMY_TMP_DIR/$1/mommy/${2:-config.sh}"
}

# Writes config string `$1` to file `$2`. Target file defaults to user config file. Creates containing directory if it
# does not exist.
write_raw() {
    path="${2:-"$(conf_file user)"}"
    mkdir -p -- "$(dirname -- "$path")"
    printf "%s" "$1" > "$path"
}

# Like `write_raw`, but sets sensible test defaults `MOMMY_COLOR=''` and `MOMMY_SUFFIX=''`, though these can be
# overridden in `$1`.
write_conf() {
    write_raw "MOMMY_COLOR='';MOMMY_SUFFIX='';$1" "$2"
}


## Run tests
Describe "mommy:"
    Describe "command-line options:"
        Describe "validation:"
            It "gives an error for unknown short options"
                When run "$MOMMY_EXEC" -z
                The error should equal "mommy doesn't know option -z~"
                The status should be failure
            End

            It "gives an error for unknown long options"
                When run "$MOMMY_EXEC" --doesnotexist
                The error should equal "mommy doesn't know option --doesnotexist~"
                The status should be failure
            End

            It "gives an error for missing required argument to short option when no command is given"
                When run "$MOMMY_EXEC" -s
                The error should equal "mommy's last option is missing its argument~"
                The status should be failure
            End
        End

        # -h/--help is tested in `integration_spec.sh`

        Describe "version information:"
            Parameters:value "-v" "--version"

            It "outputs version information [$1]"
                When run "$MOMMY_EXEC" "$1"
                The word 1 of output should equal "mommy,"
                The word 2 of output should match pattern "v%%VERSION_NUMBER%%,|v[0-9a-z\.\+]*,"
                The word 3 of output should match pattern "%%VERSION_DATE%%|[0-9]*-[0-9]*-[0-9]*"
                The status should be success
            End

            It "outputs version information even if not given as first argument [$1]"
                When run "$MOMMY_EXEC" -s 138 "$1"
                The word 1 of output should equal "mommy,"
                The word 2 of output should match pattern "v%%VERSION_NUMBER%%,|v[0-9a-z\.\+]*,"
                The word 3 of output should match pattern "%%VERSION_DATE%%|[0-9]*-[0-9]*-[0-9]*"
                The status should be success
            End
        End

        Describe "toggling output:"
            Parameters:value "-t" "--toggle"

            It "disables output when used the first time [$1]"
                "$MOMMY_EXEC" -t >/dev/null

                When run "$MOMMY_EXEC" -s 0
                The error should not be present
                The status should be success
            End

            It "disables output when used the first time even when the toggle happens inside a different shell [$1]"
                sh -c "'$MOMMY_EXEC' -t" >/dev/null

                When run sh -c "'$MOMMY_EXEC' -s 0"
                The error should not be present
                The status should be success
            End

            It "enables output again when used the second time [$1]"
                write_conf "MOMMY_COMPLIMENTS='bear soup'"

                "$MOMMY_EXEC" -t >/dev/null
                "$MOMMY_EXEC" -t >/dev/null

                When run "$MOMMY_EXEC" -s 0
                The error should equal "bear soup"
                The status should be success
            End

            It "shows an explanation when disabling mommy [$1]"
                When run "$MOMMY_EXEC" -t
                The output should include "mommy has been disabled"
            End

            It "shows an explanation when enabling mommy [$1]"
                "$MOMMY_EXEC" -t >/dev/null

                When run "$MOMMY_EXEC" -t
                The output should include "mommy has been enabled"
            End

            Describe "file management:"
                It "creates the toggle state file if it does not exist [$1]"
                    When run "$MOMMY_EXEC" -t
                    The output should be present
                    The file "$XDG_STATE_HOME/mommy/toggle" should be exist
                End

                It "deletes the toggle state file if it already exists [$1]"
                    "$MOMMY_EXEC" -t >/dev/null

                    When run "$MOMMY_EXEC" -t
                    The output should be present
                    The file "$XDG_STATE_HOME/mommy/toggle" should not be exist
                End

                It "fails to disable if the state directory cannot be created [$1]"
                    Mock mkdir
                        exit 1  # TODO[Workaround]: See https://github.com/shellspec/shellspec/issues/355
                    End

                    When run "$MOMMY_EXEC" -t
                    The error should equal "mommy could not create the state directory~"
                    The status should be failure
                End

                It "fails to disable if the state file cannot be created [$1]"
                    Mock touch
                        exit 1  # TODO[Workaround]: See https://github.com/shellspec/shellspec/issues/355
                    End

                    When run "$MOMMY_EXEC" -t
                    The error should equal "mommy could not create the state file~"
                    The status should be failure
                End

                It "fails to enable if the state file cannot be removed [$1]"
                    Mock rm
                        exit 1  # TODO[Workaround]: See https://github.com/shellspec/shellspec/issues/355
                    End

                    "$MOMMY_EXEC" -t >/dev/null

                    When run "$MOMMY_EXEC" -t
                    The error should equal "mommy could not delete the state file~"
                    The status should be failure
                End
            End
        End

        Describe "output to stdout:"
            It "outputs to stderr by default"
                write_conf "MOMMY_COMPLIMENTS='desk copper'"

                When run "$MOMMY_EXEC" true
                The output should not be present
                The error should equal "desk copper"
                The status should be success
            End

            It "outputs to stdout if '-1' is given"
                write_conf "MOMMY_COMPLIMENTS='gate friendly'"

                When run "$MOMMY_EXEC" -1 true
                The output should equal "gate friendly"
                The error should not be present
                The status should be success
            End
        End

        Describe "override user config file path:"
            Parameters:value "-c " "--config="

            It "ignores an empty path [$1]"
                When run "$MOMMY_EXEC" $1"" true
                The error should be present
                The status should be success
            End

            It "ignores an invalid path [$1]"
                When run "$MOMMY_EXEC" $1"./does_not_exist" true
                The error should be present
                The status should be success
            End

            It "ignores a directory path [$1]"
                When run "$MOMMY_EXEC" $1"." true
                The error should be present
                The status should be success
            End

            It "uses the configuration from the file [$1]"
                write_conf "MOMMY_COMPLIMENTS='apply news'" "$(conf_file foo bar.sh)"

                When run "$MOMMY_EXEC" $1"$(conf_file foo bar.sh)" true
                The error should equal "apply news"
                The status should be success
            End

            It "does not change the directory from which a role is loaded [$1]"
                write_conf "MOMMY_COMPLIMENTS='guide top'" "$(conf_file user roles/shop.sh)"

                When run "$MOMMY_EXEC" $1"$(conf_file foo bar.sh)" --role=shop true
                The error should equal "guide top"
                The status should be success
            End
        End

        Describe "set user config directory:"
            Parameters:value "-u " "--user-config-dir="

            It "changes the directory from which the user config is loaded [$1]"
                write_conf "MOMMY_COMPLIMENTS='beam bowel'" "$(conf_file foo)"

                When run "$MOMMY_EXEC" $1"$(conf_dir foo)" true
                The error should equal "beam bowel"
                The status should be success
            End

            It "does not change the directory from which the user config is loaded if -c/--config is used"
                write_conf "MOMMY_COMPLIMENTS='tent pipe'" "$(conf_file foo bar.sh)"

                When run "$MOMMY_EXEC" $1"$(conf_dir baz)" -c "$(conf_file foo bar.sh)" true
                The error should equal "tent pipe"
                The status should be success
            End

            It "changes the directory from which the role is loaded [$1]"
                write_conf "MOMMY_COMPLIMENTS='teach risk'" "$(conf_file foo roles/width.sh)"

                When run "$MOMMY_EXEC" $1"$(conf_dir foo)" -r width true
                The error should equal "teach risk"
                The status should be success
            End
        End

        Describe "set global config directory:"
            Parameters:value "-d " "--global-config-dirs="

            It "gives an error when no argument is given [$1]"
                When run "$MOMMY_EXEC" $1"" true
                The error should equal "mommy is missing the argument for option '$(strip_opt "$1")'~"
                The status should be failure
            End

            It "uses the config file in the specified directory [$1]"
                write_conf "MOMMY_COMPLIMENTS='sport revive'" "$(conf_file foo)"

                When run "$MOMMY_EXEC" $1"$(conf_dir foo)" true
                The error should equal "sport revive"
                The status should be success
            End

            It "skips non-existing global config dirs until one is found that exists [$1]"
                write_conf "MOMMY_COMPLIMENTS='cherry crop'" "$(conf_file foo)"

                When run "$MOMMY_EXEC" $1"$(conf_dir bar):$(conf_dir foo)" true
                The error should equal "cherry crop"
                The status should be success
            End

            It "skips global config dirs without the appropriate file until one is found that exists [$1]"
                mkdir -p "$(conf_file foo)"
                write_conf "MOMMY_COMPLIMENTS='paper load'" "$(conf_file bar)"

                When run "$MOMMY_EXEC" $1"$(conf_dir foo):$(conf_dir bar)" true
                The error should equal "paper load"
                The status should be success
            End

            It "when multiple global config files exist, only the first is used [$1]"
                write_conf "MOMMY_COMPLIMENTS='film style'" "$(conf_file foo)"
                write_conf "MOMMY_COMPLIMENTS='care smile'" "$(conf_file bar)"

                When run "$MOMMY_EXEC" $1"$(conf_dir foo):$(conf_dir bar)" true
                The error should equal "film style"
                The status should be success
            End
        End

        Describe "roles:"
            Parameters:value "-r " "--role="

            It "gives an error if the role string is empty [$1]"
                When run "$MOMMY_EXEC" $1"" true
                The error should equal "mommy is missing the argument for option '$(strip_opt "$1")'~"
                The status should be failure
            End

            It "gives an error if the role exists in neither global config dirs nor in the user config dir [$1]"
                When run "$MOMMY_EXEC" $1"axis" true
                The error should equal "mommy does not know the role 'axis'~"
                The status should be failure
            End

            It "loads the given role if it exists in the global config dirs and not in the user config dir [$1]"
                write_conf "MOMMY_COMPLIMENTS='gain calf'" "$(conf_file user roles/burst.sh)"

                When run "$MOMMY_EXEC" $1"burst" true
                The error should equal "gain calf"
                The status should be success
            End

            It "loads the given role if it exists in the user config dir and not in the global config dirs [$1]"
                write_conf "MOMMY_COMPLIMENTS='lock lie'" "$(conf_file global roles/essay.sh)"

                When run "$MOMMY_EXEC" $1"essay" true
                The error should equal "lock lie"
                The status should be success
            End

            It "loads the given role from the user config dir even if it also exists in the global config dirs [$1]"
                write_conf "MOMMY_PREFIX='!'" "$(conf_file global roles/plot.sh)"
                write_conf "MOMMY_COMPLIMENTS='rise part'" "$(conf_file user roles/plot.sh)"

                When run "$MOMMY_EXEC" $1"plot" true
                The error should equal "rise part"
                The status should be success
            End
        End

        Describe "config load order:"
            It "user config overrides global config"
                write_conf "MOMMY_COMPLIMENTS='ceremony isolation'" "$(conf_file global)"
                write_conf "MOMMY_COMPLIMENTS='lesson literature'" "$(conf_file user)"

                When run "$MOMMY_EXEC" true
                The error should equal "lesson literature"
                The status should be success
            End

            It "role overrides global config"
                write_conf "MOMMY_COMPLIMENTS='bark lunch'" "$(conf_file global)"
                write_conf "MOMMY_COMPLIMENTS='gas shape'" "$(conf_file user roles/urge.sh)"

                When run "$MOMMY_EXEC" -r urge true
                The error should equal "gas shape"
                The status should be success
            End

            It "role overrides user config"
                write_conf "MOMMY_COMPLIMENTS='palm inn'" "$(conf_file user)"
                write_conf "MOMMY_COMPLIMENTS='take nest'" "$(conf_file user roles/high.sh)"

                When run "$MOMMY_EXEC" -r high true
                The error should equal "take nest"
                The status should be success
            End

            It "overrides cascade, from global to user to role"
                write_raw "MOMMY_COMPLIMENTS='steel cry';MOMMY_PREFIX='!';MOMMY_SUFFIX='@';MOMMY_COLOR=''" "$(conf_file global)"
                write_raw "MOMMY_COMPLIMENTS='item fish';MOMMY_PREFIX='%'" "$(conf_file user)"
                write_raw "MOMMY_COMPLIMENTS='tasty laser'" "$(conf_file user roles/level.sh)"

                When run "$MOMMY_EXEC" -r level true
                The error should equal "%tasty laser@"
                The status should be success
            End
        End

        Describe "variadic command:"
            It "writes a compliment to stderr if the command returns 0 status"
                write_conf "MOMMY_COMPLIMENTS='purpose wall'"

                When run "$MOMMY_EXEC" true
                The error should equal "purpose wall"
                The status should be success
            End

            It "writes an encouragement to stderr if the command returns non-0 status"
                write_conf "MOMMY_ENCOURAGEMENTS='razor woolen'"

                When run "$MOMMY_EXEC" false
                The error should equal "razor woolen"
                The status should be failure
            End

            It "returns the non-0 status of the command"
                When run "$MOMMY_EXEC" exit 4
                The error should be present
                The status should equal 4
            End

            It "passes all arguments to the command"
                write_conf "MOMMY_COMPLIMENTS='disagree mean'"

                When run "$MOMMY_EXEC" echo a b c
                The output should equal "a b c"
                The error should equal "disagree mean"
                The status should be success
            End

            It "separates arguments to mommy and arguments to the command"
                write_conf "MOMMY_COMPLIMENTS='pot bond'"

                When run "$MOMMY_EXEC" -d / echo a b c
                The output should equal "a b c"
                The error should equal "pot bond"
                The status should be success
            End
        End

        Describe "eval without pipes:"
            Parameters:value "-e " "--eval="

            It "gives an error when no argument is given [$1]"
                When run "$MOMMY_EXEC" $1""
                The error should equal "mommy is missing the argument for option '$(strip_opt "$1")'~"
                The status should be failure
            End

            It "writes a compliment to stderr if the evaluated command returns 0 status [$1]"
                write_conf "MOMMY_COMPLIMENTS='bold accord'"

                When run "$MOMMY_EXEC" $1"true"
                The error should equal "bold accord"
                The status should be success
            End

            It "writes an encouragement to stderr if the evaluated command returns non-0 status [$1]"
                write_conf "MOMMY_ENCOURAGEMENTS='head log'"

                When run "$MOMMY_EXEC" $1"false"
                The error should equal "head log"
                The status should be failure
            End

            It "returns the non-0 status of the evaluated command [$1]"
                When run "$MOMMY_EXEC" $1"exit 4"
                The error should be present
                The status should equal 4
            End

            It "passes all arguments to the command [$1]"
                write_conf "MOMMY_COMPLIMENTS='desire bread'"

                When run "$MOMMY_EXEC" $1"echo a b c"
                The output should equal "a b c"
                The error should equal "desire bread"
                The status should be success
            End
        End

        Describe "eval and pipefail:"
            Describe "pipefail without eval:"
                It "does not fail if '--version' is used with '--pipefail'"
                    When run "$MOMMY_EXEC" -p -v
                    The output should be present
                    The error should not be present
                    The status should be success
                End

                It "fails if '--status' is used with '--pipefail'"
                    When run "$MOMMY_EXEC" -p -s 0
                    The output should not be present
                    The error should include "mommy supports option -p/--pipefail only"
                    The status should be failure
                End
            End

            Describe "without pipefail option:"
                Parameters:value "-e " "--eval="

                It "considers the command a success if all parts succeed [$1]"
                    write_conf "MOMMY_COMPLIMENTS='milk literary'"

                    When run "$MOMMY_EXEC" $1"echo 'faith cap' | grep -q 'faith'"
                    The error should equal "milk literary"
                    The status should be success
                End

                It "considers the command a failure if the last part fails [$1]"
                    write_conf "MOMMY_ENCOURAGEMENTS='bear cupboard'"

                    When run "$MOMMY_EXEC" $1"echo 'try thick' | grep -q 'sail'"
                    The error should equal "bear cupboard"
                    The status should be failure
                End

                It "considers the command a success even if only a non-last part fails [$1]"
                    write_conf "MOMMY_COMPLIMENTS='pony skin'"

                    When run "$MOMMY_EXEC" $1"echo 'dozen pluck' | grep -q 'prize' | cat"
                    The error should equal "pony skin"
                    The status should be success
                End
            End

            Describe "with pipefail option:"
                # shellcheck disable=SC3040 # That's the point
                pipefail_not_supported() { ! (set -o pipefail 2>/dev/null); }
                Skip if "pipefail is not supported" pipefail_not_supported


                Parameters:value "-p -e " "-p --eval=" "-pe " "--pipefail -e " "--pipefail --eval="

                It "considers the command a success if all parts succeed [$1]"
                    write_conf "MOMMY_COMPLIMENTS='rung jam'"

                    When run "$MOMMY_EXEC" $1"echo 'shy fairy' | grep -q 'shy' | cat"
                    The error should equal "rung jam"
                    The status should be success
                End

                It "considers the command a failure if the last part fails [$1]"
                    write_conf "MOMMY_ENCOURAGEMENTS='tasty gate'"

                    When run "$MOMMY_EXEC" $1"echo 'video node' | grep -q 'grand'"
                    The error should equal "tasty gate"
                    The status should be failure
                End

                It "considers the command a failure even if only a non-last part fails [$1]"
                    write_conf "MOMMY_ENCOURAGEMENTS='old week'"

                    When run "$MOMMY_EXEC" $1"echo 'seed high' | grep -q 'clue' | cat"
                    The error should equal "old week"
                    The status should be failure
                End
            End
        End

        Describe "pass on exit code status:"
            Parameters:value "-s " "--status="

            It "gives an error when no argument is given [$1]"
                When run "$MOMMY_EXEC" $1"" true
                The error should equal "mommy is missing the argument for option '$(strip_opt "$1")'~"
                The status should be failure
            End

            It "gives an error when the given status is not an integer [$1]"
                When run "$MOMMY_EXEC" $1"kick" true
                The error should equal \
                    "mommy expected the argument for option '$(strip_opt "$1")' to be an integer, but was 'kick'~"
                The status should be failure
            End

            It "writes a compliment to stderr if the status is 0 [$1]"
                write_conf "MOMMY_COMPLIMENTS='station top'"

                When run "$MOMMY_EXEC" $1"0"
                The error should equal "station top"
                The status should be success
            End

            It "writes an encouragement to stderr if the status is non-0 [$1]"
                write_conf "MOMMY_ENCOURAGEMENTS='mend journey'"

                When run "$MOMMY_EXEC" $1"1"
                The error should equal "mend journey"
                The status should be failure
            End

            It "returns the given non-0 status [$1]"
                When run "$MOMMY_EXEC" $1"167"
                The error should be present
                The status should equal 167
            End
        End
    End

    Describe "configuration:"
        Describe "templates:"
            Describe "selection sources:"
                It "chooses from 'MOMMY_COMPLIMENTS'"
                    write_conf "MOMMY_COMPLIMENTS='spill drown'"

                    When run "$MOMMY_EXEC" true
                    The error should equal "spill drown"
                    The status should be success
                End

                It "chooses from 'MOMMY_COMPLIMENTS_EXTRA'"
                    write_conf "MOMMY_COMPLIMENTS='';MOMMY_COMPLIMENTS_EXTRA='bill lump'"

                    When run "$MOMMY_EXEC" true
                    The error should equal "bill lump"
                    The status should be success
                End

                It "outputs nothing if no compliments are set"
                    write_conf "MOMMY_COMPLIMENTS='';MOMMY_COMPLIMENTS_EXTRA=''"

                    When run "$MOMMY_EXEC" true
                    The error should not be present
                    The status should be success
                End
            End

            Describe "separators:"
                It "inserts a separator between 'MOMMY_COMPLIMENTS' and 'MOMMY_COMPLIMENTS_EXTRA'"
                    write_conf "MOMMY_COMPLIMENTS='curse';MOMMY_COMPLIMENTS_EXTRA='dear'"

                    When run "$MOMMY_EXEC" true
                    The error should not equal "curse dear"
                    The status should be success
                End

                It "uses / as a separator"
                    write_conf "MOMMY_COMPLIMENTS='boy/only'"

                    When run "$MOMMY_EXEC" true
                    The error should not equal "boy/only"
                    The status should be success
                End

                It "uses a newline as a separator"
                    write_conf "MOMMY_COMPLIMENTS='salt${n}staff'"

                    When run "$MOMMY_EXEC" true
                    The error should not equal "salt${n}staff"
                    The status should be success
                End

                It "removes entries containing only whitespace"
                    # Probability of ~1/30 to pass even if code is buggy

                    write_conf "MOMMY_COMPLIMENTS='  /  /wage rot/  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  /  '"

                    When run "$MOMMY_EXEC" true
                    The error should equal "wage rot"
                    The status should be success
                End
            End

            Describe "comments:"
                It "ignores lines starting with '#'"
                    write_conf "MOMMY_COMPLIMENTS='weaken${n}#egg'"

                    When run "$MOMMY_EXEC" true
                    The error should equal "weaken"
                    The status should be success
                End

                It "does not ignore lines starting with ' #'"
                    write_conf "MOMMY_COMPLIMENTS=' #seat'"

                    When run "$MOMMY_EXEC" true
                    The error should equal " #seat"
                    The status should be success
                End

                It "does not ignore lines with a '#' not at the start"
                    write_conf "MOMMY_COMPLIMENTS='lo#ud'"

                    When run "$MOMMY_EXEC" true
                    The error should equal "lo#ud"
                    The status should be success
                End

                It "ignores the '/' in a comment line"
                    write_conf "MOMMY_COMPLIMENTS='figure${n}#penny/some'"

                    When run "$MOMMY_EXEC" true
                    The error should equal "figure"
                    The status should be success
                End
            End

            Describe "whitespace in entries:"
                It "retains leading whitespace in an entry"
                    write_conf "MOMMY_COMPLIMENTS=' rake fix'"

                    When run "$MOMMY_EXEC" true
                    The error should equal " rake fix"
                    The status should be success
                End

                It "retains trailing whitespace in an entry"
                    write_conf "MOMMY_COMPLIMENTS='read wealth '"

                    When run "$MOMMY_EXEC" true
                    The error should equal "read wealth "
                    The status should be success
                End
            End

            Describe "toggling:"
                It "outputs nothing if a command succeeds but compliments are disabled"
                    write_conf "MOMMY_COMPLIMENTS_ENABLED='0'"

                    When run "$MOMMY_EXEC" true
                    The error should not be present
                    The status should be success
                End

                It "outputs nothing if a command fails but encouragements are disabled"
                    write_conf "MOMMY_ENCOURAGEMENTS_ENABLED='0'"

                    When run "$MOMMY_EXEC" false
                    The error should not be present
                    The status should be failure
                End
            End
        End

        Describe "template variables:"
            It "escapes sed-specific characters"
                write_conf "MOMMY_COMPLIMENTS='>%%SWEETIE%%<';MOMMY_SWEETIE='&\\'"

                When run "$MOMMY_EXEC" true
                The error should equal ">&\\<"
                The status should be success
            End

            It "replaces %%SWEETIE%%"
                write_conf "MOMMY_COMPLIMENTS='>%%SWEETIE%%<';MOMMY_SWEETIE='attempt'"

                When run "$MOMMY_EXEC" true
                The error should equal ">attempt<"
                The status should be success
            End

            It "replaces %%CAREGIVER%%"
                write_conf "MOMMY_COMPLIMENTS='>%%CAREGIVER%%<';MOMMY_CAREGIVER='help'"

                When run "$MOMMY_EXEC" true
                The error should equal ">help<"
                The status should be success
            End

            It "replaces %%N%%"
                write_conf "MOMMY_COMPLIMENTS='>bottom%%N%%stimky<'"

                When run "$MOMMY_EXEC" true
                The error should equal ">bottom
stimky<"
                The status should be success
            End

            It "replaces %%S%%"
                write_conf "MOMMY_COMPLIMENTS='>global%%S%%seminar<'"

                When run "$MOMMY_EXEC" true
                The error should equal ">global/seminar<"
                The status should be success
            End

            It "replaces %%_%%"
                write_conf "MOMMY_COMPLIMENTS='>model%%_%%punish<'"

                When run "$MOMMY_EXEC" true
                The error should equal ">model punish<"
                The status should be success
            End

            It "replaces %%_%% inside pronouns"
                write_conf "MOMMY_COMPLIMENTS='>%%THEY%%<';MOMMY_PRONOUNS='nor%%_%%mal tumble source land storm'"

                When run "$MOMMY_EXEC" true
                The error should equal ">nor mal<"
                The status should be success
            End

            It "prepends the prefix"
                write_conf "MOMMY_COMPLIMENTS='<';MOMMY_PREFIX='woolen'"

                When run "$MOMMY_EXEC" true
                The error should equal "woolen<"
                The status should be success
            End

            It "appends the suffix"
                write_conf "MOMMY_COMPLIMENTS='>';MOMMY_SUFFIX='respect'"

                When run "$MOMMY_EXEC" true
                The error should equal ">respect"
                The status should be success
            End

            It "chooses a random word for a variable"
                # Runs mommy several times and checks if output is different at least once.
                # Probability of 1/(26^4)=1/456976 to fail even if code is correct.

                caregiver="a/b/c/d/e/f/g/h/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"
                write_conf "MOMMY_COMPLIMENTS='>%%CAREGIVER%%<';MOMMY_CAREGIVER='$caregiver'"

                output1=$("$MOMMY_EXEC" true 2>&1)
                output2=$("$MOMMY_EXEC" true 2>&1)
                output3=$("$MOMMY_EXEC" true 2>&1)
                output4=$("$MOMMY_EXEC" true 2>&1)
                output5=$("$MOMMY_EXEC" true 2>&1)

                [ "$output1" != "$output2" ] || [ "$output1" != "$output3" ] \
                                             || [ "$output1" != "$output4" ] \
                                             || [ "$output1" != "$output5" ]
                is_different="$?"

                When call test "$is_different" -eq 0
                The status should be success
            End

            It "chooses the empty string if a variable is not set"
                write_conf "MOMMY_COMPLIMENTS='>%%SWEETIE%%|%%THEIR%%<';MOMMY_SWEETIE='';MOMMY_PRONOUNS=''"

                When run "$MOMMY_EXEC" true
                The error should equal ">|<"
                The status should be success
            End

            Describe "pronouns:"
                It "replaces %%THEY%%"
                    write_conf "MOMMY_COMPLIMENTS='>%%THEY%%<';MOMMY_PRONOUNS='front lean weekend range great'"

                    When run "$MOMMY_EXEC" true
                    The error should equal ">front<"
                    The status should be success
                End

                It "replaces %%THEM%%"
                    write_conf "MOMMY_COMPLIMENTS='>%%THEM%%<';MOMMY_PRONOUNS='paint heighten well have spoil'"

                    When run "$MOMMY_EXEC" true
                    The error should equal ">heighten<"
                    The status should be success
                End

                It "replaces %%THEIR%%"
                    write_conf "MOMMY_COMPLIMENTS='>%%THEIR%%<';MOMMY_PRONOUNS='sink satisfy razor fox dirty'"

                    When run "$MOMMY_EXEC" true
                    The error should equal ">razor<"
                    The status should be success
                End

                It "replaces %%THEIRS%%"
                    write_conf "MOMMY_COMPLIMENTS='>%%THEIRS%%<';MOMMY_PRONOUNS='medal worth ride thrust poetry'"

                    When run "$MOMMY_EXEC" true
                    The error should equal ">thrust<"
                    The status should be success
                End

                It "replaces %%THEMSELF%%"
                    write_conf "MOMMY_COMPLIMENTS='>%%THEMSELF%%<';MOMMY_PRONOUNS='accept belong fever forge manner'"

                    When run "$MOMMY_EXEC" true
                    The error should equal ">manner<"
                    The status should be success
                End

                It "replaces %%THEIRS%% with an induced default value if only three words are given"
                    write_conf "MOMMY_COMPLIMENTS='>%%THEIRS%%<';MOMMY_PRONOUNS='singer medium bow'"

                    When run "$MOMMY_EXEC" true
                    The error should equal ">bows<"
                    The status should be success
                End

                It "replaces %%THEMSELF%% with an induced default value if only three words are given"
                    write_conf "MOMMY_COMPLIMENTS='>%%THEMSELF%%<';MOMMY_PRONOUNS='load aunt hell'"

                    When run "$MOMMY_EXEC" true
                    The error should equal ">auntself<"
                    The status should be success
                End

                It "chooses a consistent set of pronouns"
                    write_conf "MOMMY_COMPLIMENTS='>%%THEY%%.%%THEM%%.%%THEIR%%.%%THEIRS%%.%%THEMSELF%%<';\
                                MOMMY_PRONOUNS='a b c d e/f g h i j'"

                    When run "$MOMMY_EXEC" true
                    The error should match pattern ">a.b.c.d.e<|>f.g.h.i.j<"
                    The status should be success
                End
            End
        End

        Describe "capitalization:"
            It "changes the first character to lowercase if configured to 0"
                write_conf "MOMMY_COMPLIMENTS='Alive station';MOMMY_CAPITALIZE='0'"

                When run "$MOMMY_EXEC" true
                The error should equal "alive station"
                The status should be success
            End

            It "changes the first character to uppercase if configured to 1"
                write_conf "MOMMY_COMPLIMENTS='inquiry speech';MOMMY_CAPITALIZE='1'"

                When run "$MOMMY_EXEC" true
                The error should equal "Inquiry speech"
                The status should be success
            End

            It "uses the template's original capitalization if configured to the empty string"
                write_conf "MOMMY_COMPLIMENTS='Medicine frighten';MOMMY_CAPITALIZE="

                When run "$MOMMY_EXEC" true
                The error should equal "Medicine frighten"
                The status should be success
            End

            It "uses the template's original capitalization if configured to anything else"
                write_conf "MOMMY_COMPLIMENTS='Belong shore';MOMMY_CAPITALIZE='2'"

                When run "$MOMMY_EXEC" true
                The error should equal "Belong shore"
                The status should be success
            End
        End

        Describe "forbidden words:"
            # Repeat 5 times because of randomization
            Parameters:value 1 2 3 4 5

            It "removes the template that equals the forbidden word [$1]"
                write_conf "MOMMY_COMPLIMENTS='mother search/fierce along';MOMMY_FORBIDDEN_WORDS='search'"

                When run "$MOMMY_EXEC" true
                The error should equal "fierce along"
                The status should be success
            End

            It "removes the template that contains the forbidden word [$1]"
                write_conf "MOMMY_COMPLIMENTS='clear bow flow/horn origin tired';MOMMY_FORBIDDEN_WORDS='bow'"

                When run "$MOMMY_EXEC" true
                The error should equal "horn origin tired"
                The status should be success
            End

            It "removes all templates that contain a forbidden word [$1]"
                write_conf "MOMMY_COMPLIMENTS='after boundary/failure school/instant delay';\
                            MOMMY_FORBIDDEN_WORDS='instant/boundary'"

                When run "$MOMMY_EXEC" true
                The error should equal "failure school"
                The status should be success
            End

            It "removes all templates that match the bracket expansion [$1]"
                write_conf "MOMMY_COMPLIMENTS='a/z/c';MOMMY_FORBIDDEN_WORDS='[ac]'"

                When run "$MOMMY_EXEC" true
                The error should equal "z"
                The status should be success
            End

            It "removes all templates that match the bracket expansion range [$1]"
                write_conf "MOMMY_COMPLIMENTS='a/b/c/z';MOMMY_FORBIDDEN_WORDS='[a-c]'"

                When run "$MOMMY_EXEC" true
                The error should equal "z"
                The status should be success
            End

            It "maps octal escapes to the corresponding character [$1]"
                write_conf "MOMMY_COMPLIMENTS='z/a/b';MOMMY_FORBIDDEN_WORDS='[\0141\0142]'"

                When run "$MOMMY_EXEC" true
                The error should equal "z"
                The status should be success
            End

            It "maps octal escapes to the corresponding character in a range [$1]"
                write_conf "MOMMY_COMPLIMENTS='z/a/b';MOMMY_FORBIDDEN_WORDS='[\0141\0142]'"

                When run "$MOMMY_EXEC" true
                The error should equal "z"
                The status should be success
            End

            It "supports the | in a regex [$1]"
                write_conf "MOMMY_COMPLIMENTS='dinner/rent/shot';MOMMY_FORBIDDEN_WORDS='(dinner|rent)'"

                When run "$MOMMY_EXEC" true
                The error should equal "shot"
                The status should be success
            End

            It "does not output anything even if the list only matches after variable substitutions [$1]"
                write_conf "MOMMY_COMPLIMENTS='%%THEY%%%%THEM%%';\
                            MOMMY_PRONOUNS='a b c d e';\
                            MOMMY_FORBIDDEN_WORDS='(ab)'"

                When run "$MOMMY_EXEC" true
                The error should not be present
                The status should be success
            End
        End

        Describe "ignore specific exit codes:"
            It "by default, outputs something"
                When run "$MOMMY_EXEC" exit 0
                The error should be present
                The status should be success
            End

            It "by default, outputs nothing if the exit code is 130"
                When run "$MOMMY_EXEC" exit 130
                The error should not be present
                The status should equal 130
            End

            It "outputs something if no exit code is suppressed"
                write_conf "MOMMY_IGNORED_STATUSES=''"

                When run "$MOMMY_EXEC" exit 130
                The error should be present
                The status should equal 130
            End

            It "output nothing if the exit code is the configured value"
                write_conf "MOMMY_IGNORED_STATUSES='32'"

                When run "$MOMMY_EXEC" exit 32
                The error should not be present
                The status should equal 32
            End

            It "does not output anything if the exit code is one of the configured values"
                write_conf "MOMMY_IGNORED_STATUSES='32/84/89'"

                When run "$MOMMY_EXEC" exit 84
                The error should not be present
                The status should equal 84
            End
        End
    End
End
