{ lib
, fetchFromGitHub
, python3
, anki
}:

python3.pkgs.buildPythonApplication rec {
  pname = "ankisyncd";
  version = "2.1.0";
  src = fetchFromGitHub {
    owner = "tsudoko";
    repo = "anki-sync-server";
    rev = version;
    sha256 = "6a140afa94fdb1725fed716918875e3d2ad0092cb955136e381c9d826cc4927c";
  };
  format = "other";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/${python3.sitePackages}

    cp -r ankisyncd utils ankisyncd.conf $out/${python3.sitePackages}
    mkdir $out/share
    cp ankisyncctl.py $out/share/

    runHook postInstall
  '';

  fixupPhase = ''
    PYTHONPATH="$PYTHONPATH:$out/${python3.sitePackages}:${anki}"

    makeWrapper "${python3.interpreter}" "$out/bin/ankisyncd" \
          --set PYTHONPATH $PYTHONPATH \
          --add-flags "-m ankisyncd"

    makeWrapper "${python3.interpreter}" "$out/bin/ankisyncctl" \
          --set PYTHONPATH $PYTHONPATH \
          --add-flags "$out/share/ankisyncctl.py"
  '';

  checkInputs = with python3.pkgs; [
    pytest
    webtest
  ];

  buildInputs = [ ];

  requiredPythonModules = [ anki ];

  checkPhase = ''
    # Exclude tests that require sqlite's sqldiff command, since
    # it isn't yet packaged for NixOS, although 2 PRs exist:
    # - https://github.com/NixOS/nixpkgs/pull/69112
    # - https://github.com/NixOS/nixpkgs/pull/75784
    # Once this is merged, these tests can be run as well.
    pytest --ignore tests/test_web_media.py tests/
  '';

  meta = with lib; {
    description = "Self-hosted Anki sync server";
    maintainers = with maintainers; [ matt-snider ];
    homepage = "https://github.com/tsudoko/anki-sync-server";
    license = licenses.agpl3;
    platforms = platforms.linux;
  };
}
