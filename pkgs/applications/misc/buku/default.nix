{ stdenv, python3, fetchFromGitHub }:

with python3.pkgs; buildPythonApplication rec {
  version = "4.4";
  pname = "buku";

  src = fetchFromGitHub {
    owner = "jarun";
    repo = "buku";
    rev = "v${version}";
    sha256 = "10r5f1n0vcxxmqqqsgmlvibwg1xffijrr2id6r140rgiyhprz556";
  };

  checkInputs = [
    pytestcov
    hypothesis
    pytest
    pylint
    flake8
    pyyaml
    mypy-extensions
  ];

  requiredPythonModules = [
    cryptography
    beautifulsoup4
    requests
    urllib3
    flask
    flask-admin
    flask-api
    flask-bootstrap
    flask-paginate
    flask-reverse-proxy-fix
    flask_wtf
    arrow
    werkzeug
    click
    html5lib
    vcrpy
    toml
  ];

  postPatch = ''
    # Jailbreak problematic dependencies
    sed -i \
      -e "s,'PyYAML.*','PyYAML',g" \
      setup.py
  '';

  preCheck = ''
    # Fixes two tests for wrong encoding
    export PYTHONIOENCODING=utf-8

    # Disables a test which requires internet
    substituteInPlace tests/test_bukuDb.py \
      --replace "@pytest.mark.slowtest" "@unittest.skip('skipping')" \
      --replace "self.assertEqual(shorturl, 'http://tny.im/yt')" "" \
      --replace "self.assertEqual(url, 'https://www.google.com')" ""
    substituteInPlace setup.py \
      --replace mypy-extensions==0.4.1 mypy-extensions>=0.4.1
  '';

  postInstall = ''
    make install PREFIX=$out

    mkdir -p $out/share/zsh/site-functions $out/share/bash-completion/completions $out/share/fish/vendor_completions.d
    cp auto-completion/zsh/* $out/share/zsh/site-functions
    cp auto-completion/bash/* $out/share/bash-completion/completions
    cp auto-completion/fish/* $out/share/fish/vendor_completions.d
  '';

  meta = with stdenv.lib; {
    description = "Private cmdline bookmark manager";
    homepage = "https://github.com/jarun/Buku";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ matthiasbeyer infinisil ];
  };
}

