local cmd = require("cmd")
local file = require("file")
local chibi = require("chibi")

-- Builds the extracted source with lib/build.sh, installing into ctx.rootPath.
function PLUGIN:PostInstall(ctx)
    if RUNTIME.osType == "windows" then
        error("chibi: Windows is not supported")
    end
    local script = file.join_path(RUNTIME.pluginDirPath, "lib", "build.sh")
    print("chibi: building chibi-scheme " .. ctx.runtimeVersion .. " from source")
    cmd.exec("sh " .. chibi.shell_quote(script), {
        env = { CHIBI_PREFIX = ctx.rootPath },
    })
end
