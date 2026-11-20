local M = {}

M.repo = "ashinn/chibi-scheme"

-- "0.12", "0.9.1" -> true; "stable" -> false
function M.is_release(version)
    return version:match("^%d+[%.%d]*$") ~= nil and version:sub(-1) ~= "."
end

-- A version mise hands us is either a release tag or a git ref (from
-- `chibi@ref:<ref>`). mise may or may not keep the "ref:" prefix.
function M.source_url(version)
    local ref = version:match("^ref:(.+)$")
    if ref then
        return "https://github.com/" .. M.repo .. "/archive/" .. ref .. ".tar.gz"
    end
    if M.is_release(version) then
        return "https://github.com/" .. M.repo .. "/archive/refs/tags/" .. version .. ".tar.gz"
    end
    -- Anything else (a branch or commit passed without the prefix).
    return "https://github.com/" .. M.repo .. "/archive/" .. version .. ".tar.gz"
end

-- Single-quote a string for POSIX sh.
function M.shell_quote(s)
    return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

return M
