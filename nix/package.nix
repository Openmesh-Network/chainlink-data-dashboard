{ pkgs }:
pkgs.buildNpmPackage {
  pname = "nextjs-app";
  version = "0";
  src = ../nextjs-app;

  # FIXME: this needs to be updated every time the package-lock.json changes
  npmDepsHash = "sha256-MLDF1QkOzrpuxq1U8l9FZpFySlj6BBnKkKVM0pG3g88=";

  postBuild = ''
    # Add a shebang to the server js file, then patch the shebang to use a
    # nixpkgs nodes binary
    sed -i '1s|^|#!/usr/bin/env node\n|' .next/standalone/server.js
    patchShebangs .next/standalone/server.js
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{share,bin}

    cp -r .next/standalone $out/share/homepage/
    # cp -r .env $out/share/homepage/
    cp -r public $out/share/homepage/public

    mkdir -p $out/share/homepage/.next
    cp -r .next/static $out/share/homepage/.next/static

    # https://github.com/vercel/next.js/discussions/58864
    ln -s /var/cache/nextjs-app $out/share/homepage/.next/cache

    chmod +x $out/share/homepage/server.js

    # we set a default port to support "nix run ..."
    makeWrapper $out/share/homepage/server.js $out/bin/nextjs-app \
      --set-default PORT 3000 \
      --set-default HOSTNAME 127.0.0.1

    runHook postInstall
  '';

  doDist = false;

  meta = {
    mainProgram = "nextjs-app";
  };
}