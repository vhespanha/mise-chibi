local file = require("file")

-- PATH only: the build bakes the module path into the binary and links with an
-- rpath (Linux) / install_name (macOS), so no LD_LIBRARY_PATH or CHIBI_MODULE_PATH.
function PLUGIN:EnvKeys(ctx)
    return {
        { key = "PATH", value = file.join_path(ctx.path, "bin") },
    }
end
