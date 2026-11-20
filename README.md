# mise-chibi

A [mise](https://mise.jdx.dev) tool plugin that builds and installs
[Chibi-Scheme](https://github.com/ashinn/chibi-scheme) from source.

Chibi-Scheme publishes no prebuilt binaries, so every install compiles it.
That takes about 10–30 seconds on a typical machine.

## Install

```sh
mise plugins install chibi https://github.com/vhespanha/mise-chibi
mise use chibi@latest        # or chibi@0.12
chibi-scheme -V
```

To build any branch, tag or commit of chibi-scheme:

```sh
mise use chibi@ref:master
```

You get `chibi-scheme`, `snow-chibi`, `chibi-ffi` and `chibi-doc`, plus the
headers, `libchibi-scheme` and `chibi-scheme.pc`.

## Requirements

- Linux or macOS. Windows is not supported.
- `make`, a C compiler and a POSIX `sh`.
  - Debian/Ubuntu: `apt install build-essential`
  - Fedora: `dnf install make gcc`
  - Arch: `pacman -S base-devel`
  - Alpine: `apk add build-base`
  - macOS: `xcode-select --install`

mise checks these before it installs (see the
[`system_deps`](https://mise.jdx.dev/configuration/settings.html#system_deps)
setting). Set `CC` to use a compiler other than `cc`.

## Configuration

| Variable                | Effect                                                                                                   |
| ----------------------- | -------------------------------------------------------------------------------------------------------- |
| `MISE_CHIBI_MAKE_FLAGS` | Extra arguments added to every `make` call, split on whitespace, e.g. `"SEXP_USE_BOEHM=1 CFLAGS=-O3"` |
| `MISE_CHIBI_RUN_TESTS`  | Set to `1` to run `make test` before installing                                                         |

```sh
MISE_CHIBI_MAKE_FLAGS="SEXP_USE_BOEHM=1" mise install chibi@0.12
```

Version listing uses the GitHub API. mise adds your GitHub token
(`GITHUB_TOKEN`, `GH_TOKEN`, `MISE_GITHUB_TOKEN` or the `gh` CLI login) to
those requests on its own, so you won't hit the anonymous rate limit.

## How it works

- **Versions** are chibi-scheme's numeric git tags. The moving `stable` tag is
  left out.
- **Download:** mise fetches the GitHub source tarball for the tag or ref.
  chibi-scheme publishes no checksums. mise records one in `mise.lock` on the
  first install.
- **Build:** `make PREFIX=<install dir>`, then `make install`. Because the
  install directory is compiled into the binary, the binary finds its modules
  and `libchibi-scheme` without `LD_LIBRARY_PATH` or `CHIBI_MODULE_PATH`. On
  Linux the plugin adds an rpath. On macOS chibi's own `install_name` does the
  same job.
- **snow-chibi** packages install into the version's own directory, not
  `/usr/local`, so reinstalling or upgrading chibi drops them. To install them
  somewhere shared, pass `SNOWPREFIX=...` in `MISE_CHIBI_MAKE_FLAGS`.
- **Environment:** only `<install dir>/bin` is added to `PATH`.

## Development

```sh
mise plugins link --force chibi .
mise ls-remote chibi
mise install chibi@0.12
mise exec chibi@0.12 -- chibi-scheme -V
```

## License

MIT
