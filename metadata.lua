PLUGIN = {
    name = "chibi",
    version = "0.1.0",
    description = "Build and install Chibi-Scheme from source",
    homepage = "https://github.com/ashinn/chibi-scheme",
    license = "MIT",

    -- Checked by mise before installing (older mise ignores this; post_install
    -- repeats the check so the failure is still readable there).
    systemDependencies = {
        { bin = "make", packages = { apt = "make", dnf = "make", pacman = "make", apk = "make", zypper = "make" } },
        { bin = "cc", packages = { apt = "build-essential", dnf = "gcc", pacman = "base-devel", apk = "build-base", zypper = "gcc" } },
        { command = "[ \"$(uname)\" != Darwin ] || xcode-select -p", optional = "Xcode Command Line Tools (macOS)" },
    },
}
