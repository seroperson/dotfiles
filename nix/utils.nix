{ dotfilesDirectory
, config
, useSymlinks
, sourceDirectory
}: rec {
  relativePath = p:
    let
      full = toString p;
      base = toString sourceDirectory;
      baseLen = builtins.stringLength base;
    in
    builtins.substring (baseLen + 1) (-1) full;

  fileReference = path:
    if useSymlinks
    then config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/${relativePath path}"
    else path;
}
