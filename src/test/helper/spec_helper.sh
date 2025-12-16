#!/bin/sh
## Configuration
# Variables defined below can be overridden when invoking `make test`. For example, `MOMMY_SYSTEM=1 make test`.

# "0" to run against files in 'src/', "1" to run against installed files
: "${MOMMY_SYSTEM:=0}"
export MOMMY_SYSTEM

# Path to mommy executable to test
if [ "x0" = "x$MOMMY_SYSTEM" ]; then
    : "${MOMMY_EXEC:=../../main/sh/mommy}"
else
    : "${MOMMY_EXEC:=mommy}"
fi
export MOMMY_EXEC

# Path to directory for temporary files
: "${MOMMY_TMP_DIR:=/tmp/mommy-test/}"
export MOMMY_TMP_DIR


## Constants and helpers
export n="
"

strip_opt() { printf "%s\n" "$1" | sed -e "s/^-\{1,\}//g" -e "s/[= ]\{1,\}\$//g"; }


## Hooks
spec_helper_configure() {
    before_all mommy_clean_tmp
    after_all mommy_clean_tmp
    before_each mommy_before_each
    after_each mommy_clean_tmp
}

mommy_clean_tmp() {
    rm -rf "$MOMMY_TMP_DIR"
}

mommy_before_each() {
    mkdir -p "$MOMMY_TMP_DIR"
}
