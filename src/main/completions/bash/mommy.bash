#!/bin/bash

## Four basics to writing Bash completions:
# COMPREPLY - array for possible completions
# COMP_WORDS - array of individual arguments typed so far
# COMP_CWORD - index of the command argument at cursor
# COMP_LINE - current command line

_mommy()
{
	local args_avail=("-c" "--config=" "-d" "--global-config-dirs=" "-e" "--eval=" "-h" "--help" "-p" "--pipefail" "-s" "--status=" "-t" "--toggle" "-v" "--version")
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
                "-c")
                	args_avail=("${args_avail[@]/-c}")
               		args_avail=("${args_avail[@]/--config=}")
                    mapfile -t COMPREPLY < <(compgen -c -- "$cur" | grep ".*sh$") ;;
                "--config=")
               		args_avail=("${args_avail[@]/-c}")
              		args_avail=("${args_avail[@]/--config=}")
                    mapfile -t COMPREPLY < <(compgen -c -- "$cur" | grep ".*sh$") ;;
                "-e")
                	args_avail=("${args_avail[@]/-e}")
                	args_avail=("${args_avail[@]/--eval=}")
                    mapfile -t COMPREPLY < <(compgen -c -- "$cur") ;;
                "--eval=")
                	args_avail=("${args_avail[@]/-e}")
                	args_avail=("${args_avail[@]/--eval=}")
                    mapfile -t COMPREPLY < <(compgen -c -- "$cur") ;;
                "-d")
                	args_avail=("${args_avail[@]/-d}")
                    args_avail=("${args_avail[@]/--global-config-dirs=}")
                    mapfile -t COMPREPLY < <(compgen -d -- "$cur") ;;
                "--global-config-dirs=")
                	args_avail=("${args_avail[@]/-d}")
                    args_avail=("${args_avail[@]/--global-config-dirs=}")
                    mapfile -t COMPREPLY < <(compgen -d -- "$cur") ;;
                "-s")
               		args_avail=("${args_avail[@]/-s}")
               		args_avail=("${args_avail[@]/--status=}")
                    COMPREPLY=("0" "1") ;;
                "--status=")
              		args_avail=("${args_avail[@]/-s}")
               		args_avail=("${args_avail[@]/--status=}")
                    COMPREPLY=("0" "1") ;;
                "-h" | "--help")
                    args_avail=("${args_avail[@]/-h}")
                    args_avail=("${args_avail[@]/--help}")
                    flag=1 ;;
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
