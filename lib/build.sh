#!/bin/sh
# Builds chibi-scheme. Called by hooks/post_install.lua with:
#   CHIBI_PREFIX           the mise install directory (holds the extracted source on entry)
#   MISE_CHIBI_MAKE_FLAGS  optional extra make arguments, split on whitespace
#   MISE_CHIBI_RUN_TESTS   "1" to run `make test` before installing
set -eu
set -f # MISE_CHIBI_MAKE_FLAGS is word-split on purpose; never glob it

prefix="$CHIBI_PREFIX"
make_flags="${MISE_CHIBI_MAKE_FLAGS:-}"

command -v make >/dev/null 2>&1 || {
    echo "chibi: 'make' not found. Install build tools first (Debian/Ubuntu: build-essential; macOS: xcode-select --install)." >&2
    exit 1
}
cc="${CC:-cc}"
command -v "$cc" >/dev/null 2>&1 || {
    echo "chibi: C compiler '$cc' not found. Install build tools first (Debian/Ubuntu: build-essential; macOS: xcode-select --install)." >&2
    exit 1
}

# mise extracted the source into the install directory; move it to a scratch
# directory so the install directory ends up holding only the installed files.
src="$(mktemp -d "${TMPDIR:-/tmp}/mise-chibi-build.XXXXXX")"
log="$src.log"
trap 'rm -rf "$src" "$log"' EXIT
set +f
for f in "$prefix"/* "$prefix"/.[!.]* "$prefix"/..?*; do
    if [ -e "$f" ] || [ -L "$f" ]; then
        mv "$f" "$src"/
    fi
done
set -f

jobs="$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)"

run() {
    if ! "$@" >>"$log" 2>&1; then
        echo "chibi: '$*' failed; last lines of the build log:" >&2
        tail -n 40 "$log" >&2
        exit 1
    fi
}

cd "$src"
# PREFIX must be the final location at build time: it is compiled into the
# binary as the module path (and as the install_name on macOS).
# On Linux chibi's Makefile sets no rpath and relies on ldconfig, which can't
# see a per-user prefix, so add one pointing at $prefix/lib.
# SNOWPREFIX defaults to /usr/local, which would make `snow-chibi install`
# need root; keep snow packages inside this version's install directory.
if [ "$(uname)" = Darwin ]; then
    set -- PREFIX="$prefix" SNOWPREFIX="$prefix"
else
    set -- PREFIX="$prefix" SNOWPREFIX="$prefix" RLDFLAGS="-Wl,-rpath,$prefix/lib"
fi
# shellcheck disable=SC2086
run make -j"$jobs" "$@" $make_flags
if [ "${MISE_CHIBI_RUN_TESTS:-}" = 1 ]; then
    # shellcheck disable=SC2086
    run make "$@" $make_flags test
fi
# shellcheck disable=SC2086
run make "$@" $make_flags install

out="$("$prefix/bin/chibi-scheme" -e '(display (+ 1 2))' 2>&1)" || true
if [ "$out" != 3 ]; then
    echo "chibi: smoke test failed: expected '3' from chibi-scheme, got: $out" >&2
    exit 1
fi
