{ stdenv
, buildPythonPackage
, fetchPypi
, numpy
, pytest
, pythonOlder
}:

buildPythonPackage rec {
  pname = "fastprogress";
  version = "1.0.0";
  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1zhv37q6jkqd1pfhlkd4yzrc3dg83vyksgzf32mjlhd5sb0qmql9";
  };

  requiredPythonModules = [ numpy ];

  # no real tests
  doCheck = false;
  pythonImportsCheck = [ "fastprogress" ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/fastai/fastprogress";
    description = "Simple and flexible progress bar for Jupyter Notebook and console";
    license = licenses.asl20;
    maintainers = with maintainers; [ ris ];
  };

}
