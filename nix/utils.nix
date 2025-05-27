{ dotfilesDirectory
, config
, useSymlinks
}: rec {
  baseName = p:
    let
      removeNixStorePrefix = nsp:
        let
          m = builtins.match "/nix/store/[^-]+-(.*)" (toString nsp);
        in
        if m == null then
          nsp
        else
          (builtins.head m);
    in
    builtins.baseNameOf (removeNixStorePrefix p);

  fileReference = path:
    if useSymlinks
    then config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/${baseName path}"
    else path;
}
