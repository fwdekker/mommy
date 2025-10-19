#!/bin/sh
## Configuration
# Make
: "${MOMMY_MAKE:=make}"  # Path to GNU make to invoke

# Man
: "${MOMMY_MAN_SKIP:=0}"  # "1" to run man-related tests, "0" to skip them

# Fish
: "${MOMMY_FISH_SKIP:=0}"  # "1" to run fish-related tests, "0" to skip them
: "${MOMMY_FISH_EXEC:=fish}"  # Path to fish to invoke

# Zsh
: "${MOMMY_ZSH_SKIP:=0}"  # "1" to run zsh-related tests, "0" to skip them
: "${MOMMY_ZSH_EXEC:=zsh}"  # Path to zsh to invoke
: "${MOMMY_ZSH_PREAMBLE_FILE:=$MOMMY_TMP_DIR/zsh_preamble.sh}"  # Path to temporary zsh preamble file


## Run tests
Describe "integration of mommy with other programs"
    Describe "uninstalling"
        is_empty() {
            test "$(find "$1/" -type f | wc -l)" -eq 0
        }

        It "uninstalls all files that are installed"
            "$MOMMY_MAKE" -C ../../../ prefix="$MOMMY_TMP_DIR/" install >/dev/null
            "$MOMMY_MAKE" -C ../../../ prefix="$MOMMY_TMP_DIR/" uninstall >/dev/null

            Assert is_empty "$MOMMY_TMP_DIR/"
        End
    End

    Describe "-h/--help: help information"
        man_is_skipped_or_not_installed() { test "$MOMMY_MAN_SKIP" = "1" || ! test -x "$(command -v man)"; }
        Skip if "man is skipped or not installed" man_is_skipped_or_not_installed

        man_before_each() {
            unset MANPATH  # Required on Windows
            if [ "$MOMMY_SYSTEM" != "1" ]; then
                MANPATH="$(readlink -f "$(pwd)/../../main/man/")"
                export MANPATH
            fi
        }
        BeforeEach "man_before_each"


        Parameters:value "-h" "--help"

        It "outputs help information using $1"
            When run "$MOMMY_EXEC" "$1"
            The word 1 of output should equal "mommy(1)"
            The status should be success
        End

        It "outputs help information even when $1 is not the first option"
            When run "$MOMMY_EXEC" -s 432 "$1"
            The word 1 of output should equal "mommy(1)"
            The status should be success
        End

        It "outputs a link to github if the manual page could not be found when using $1"
            export MANPATH="/invalid-path"

            When run "$MOMMY_EXEC" "$1"
            The output should equal ""
            The error should include "github.com"
            The status should be failure
        End
    End

    Describe "fish shell autocompletion"
        fish_is_skipped_or_not_installed() { test "$MOMMY_FISH_SKIP" = "1" || ! test -x "$(command -v "$MOMMY_FISH_EXEC")"; }
        Skip if "fish is skipped or not installed" fish_is_skipped_or_not_installed

        fish_before_each() {
            if [ "$MOMMY_SYSTEM" != "1" ]; then
                fish_preamble="
                    fish_add_path --path --prepend '$(pwd)/../../main/sh/'  # Fish requires executable to be on path
                    set fish_complete_path '$(pwd)/../../main/completions/fish/' \$fish_complete_path
                "
            fi
        }
        BeforeEach "fish_before_each"

        fish_complete() {
            "$MOMMY_FISH_EXEC" -c "$fish_preamble; complete -C '$1'"
        }


        It "outputs an option if the argument starts with -"
            When run fish_complete "mommy -"
            The output should include "-1"
        End

        It "outputs files if the previous option was -c"
            When run fish_complete "mommy -c "
            The output should include "integration_spec.sh"
        End
    End

    Describe "zsh shell autocompletion"
        zsh_is_skipped_or_not_installed() { test "$MOMMY_ZSH_SKIP" = "1" || ! test -x "$(command -v "$MOMMY_ZSH_EXEC")"; }
        Skip if "zsh is skipped or not installed" zsh_is_skipped_or_not_installed

        zsh_before_each() {
            printf "source '%s/../resources/zsh_loader.zsh'\n" "$(pwd)" > "$MOMMY_ZSH_PREAMBLE_FILE"
            if [ "$MOMMY_SYSTEM" != "1" ]; then
                printf "FPATH='%s/../../main/completions/zsh/:'\"\$FPATH\"\n" "$(pwd)" >> "$MOMMY_ZSH_PREAMBLE_FILE"
            fi
            printf "autoload -U compinit; compinit -u\n" >> "$MOMMY_ZSH_PREAMBLE_FILE"
        }
        BeforeEach "zsh_before_each"

        zsh_complete() {
            # Records the output generated in a terminal when completions are requested for `$1` in zsh.
            #
            # `script` emulates an interactive terminal during GitHub actions. Unfortunately, the interface of `script`
            # varies significantly between distributions. This function unifies the desired behaviour. It's not pretty.

            printf "%s\n%s" \
                "#!/bin/sh" \
                "\"$MOMMY_ZSH_EXEC\" -i -u -c \"source '$MOMMY_ZSH_PREAMBLE_FILE'; compget '$1'\"" \
                > /tmp/mommy-script
            chmod +x /tmp/mommy-script

            case "$(uname)" in
                Darwin|FreeBSD)
                    # macOS/Freebsd: Has no `-c` option, so command must be specified as a vararg
                    script -q /dev/null /tmp/mommy-script
                    ;;
                OpenBSD)
                    # OpenBSD: Has no `-q` option, so output is written to file, and then header and footer are stripped
                    script -c /tmp/mommy-script /tmp/mommy-script-out 1>/dev/null 2>/dev/null
                    tail -n +2 /tmp/mommy-script-out | head -n 1
                    rm -f /tmp/mommy-script-out
                    ;;
                *)
                    # Linux / NetBSD
                    script -q -c /tmp/mommy-script /dev/null
                    ;;
            esac

            rm -f /tmp/mommy-script
        }


        It "outputs an option if the argument starts with -"
            When run zsh_complete "mommy -"
            The output should include "-1"
        End

        It "outputs files if the previous option was -c"
            When run zsh_complete "mommy -c "
            The output should include "integration_spec.sh"
        End
    End

    Describe "--rename and --remove-rename: renaming the executable"
        skip_if_not_root() {
            if [ "$(id -u)" -ne 0 ]; then
                Skip "not running as root"
            fi
        }

        rename_setup() {
            # Create a temporary bin directory
            rename_test_bin="$MOMMY_TMP_DIR/bin"
            mkdir -p "$rename_test_bin"
            
            # Copy mommy script to test directory if not using system installation
            if [ "$MOMMY_SYSTEM" = "1" ]; then
                mommy_path="$(command -v mommy)"
            else
                mommy_path="$(cd "../../main/sh" && pwd)/mommy"
            fi
            
            cp "$mommy_path" "$rename_test_bin/mommy"
            chmod +x "$rename_test_bin/mommy"
            
            # Set up test environment
            rename_exec="$rename_test_bin/mommy"
            rename_test_name="testmommy"
        }

        BeforeEach "rename_setup"

        It "requires root privileges for --rename"
            When run "$rename_exec" --rename="$rename_test_name" true
            The error should match pattern "root|Root|ROOT|permission"
            The status should be failure
        End

        It "requires root privileges for --remove-rename"
            When run "$rename_exec" --remove-rename="$rename_test_name" true
            The error should match pattern "root|Root|ROOT|permission"
            The status should be failure
        End

        It "fails when renames file doesn't exist for --remove-rename"
            When run "$rename_exec" --remove-rename="nonexistent" true
            The error should match pattern "no renames|doesn't have"
            The status should be failure
        End

        It "handles missing arguments correctly for --rename"
            When run "$rename_exec" --rename="" true
            The error should match pattern "missing|required"
            The status should be failure
        End

        It "handles missing arguments correctly for --remove-rename"
            When run "$rename_exec" --remove-rename="" true
            The error should match pattern "missing|required"
            The status should be failure
        End

        It "preserves mommy functionality after rename check"
            set_config "MOMMY_COMPLIMENTS='rename works'"
            
            When run "$rename_exec" -c "$MOMMY_CONFIG_FILE" true
            The error should equal "rename works"
            The status should be success
        End
    End
End
