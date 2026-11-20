local chibi = require("chibi")

-- Points mise at the source tarball. mise downloads and extracts it into the
-- install directory; post_install moves it aside and builds it.
--
-- No sha256: chibi-scheme publishes no checksums for its source archives.
-- mise.lock records the checksum of the first download.
function PLUGIN:PreInstall(ctx)
    return {
        version = ctx.version,
        url = chibi.source_url(ctx.version),
    }
end
