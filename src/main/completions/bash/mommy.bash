## Four basics to writing Bash completions:
# COMPREPLY - array for possible completions
# COMP_WORDS - array of individual arguments typed so far
# COMP_CWORD - index of the command argument at cursor
# COMP_LINE - current command line

_mommy()
{
	local args_avail=( \
	    "-h" "--help" \
	    "-t" "--toggle" \
	    "-v" "--version" \
	    "-e" "--eval=" \
	    "-p" "--pipefail" \
	    "-s" "--status=" \
	    "-d" "--global-config-dirs=" \
	    "-u" "--user-config-dir=" \
	    "-r" "--role=" \
    )
    local cur="${COMP_WORDS[COMP_CWORD]}"

    if [[ "$COMP_CWORD" -eq 1 ]]; then
        mapfile -t COMPREPLY < <(compgen -W "${args_avail[*]}" -- "$cur")
        return
    fi

    flag=0

    while [[ "$flag" -eq 0 ]]; do
        local argument="${COMP_WORDS[ ((COMP_CWORD - 1)) ]}"
        if [[ "$COMP_CWORD" -ge 2 ]]; then
            case "$argument" in
                "-h" | "--help")
                    args_avail=("${args_avail[@]/-h}")
                    args_avail=("${args_avail[@]/--help}")
                    flag=1 ;;
                "-d" | "--global-config-dirs=")
                	args_avail=("${args_avail[@]/-d}")
                    args_avail=("${args_avail[@]/--global-config-dirs=}")
                    mapfile -t COMPREPLY < <(compgen -A directory -- "$cur") ;;
                "-r" | "--role=")
                	args_avail=("${args_avail[@]/-r}")
                    args_avail=("${args_avail[@]/--role=}")
                    COMPREPLY=() ;;
                "-e" | "--eval=")
                	args_avail=("${args_avail[@]/-e}")
                	args_avail=("${args_avail[@]/--eval=}")
                    mapfile -t COMPREPLY < <(compgen -A command -- "$cur") ;;
                "-s" | "--status=")
               		args_avail=("${args_avail[@]/-s}")
               		args_avail=("${args_avail[@]/--status=}")
                    COMPREPLY=("0" "1") ;;
                "-t" | "--toggle")
                    args_avail=("${args_avail[@]/-t}")
                    args_avail=("${args_avail[@]/--toggle}")
                    flag=1 ;;
                "-p" | "--pipefail")
               		args_avail=("${args_avail[@]/-p}")
                	args_avail=("${args_avail[@]/--pipefail}")
                    mapfile -t COMPREPLY < <(compgen -W "${args_avail[*]}" -- "$cur") ;;
            esac
            return
        fi
    done
}
complete -F _mommy mommy
