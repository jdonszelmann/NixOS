{ pkgs, lib, fetchFromGitHub, python39Packages }:

with python39Packages;

let
  # officially supported database drivers
  dbDrivers = [
    psycopg2
    # sqlite driver is already shipped with python by default
  ];

in
buildPythonPackage rec {
  pname = "matrix-registration";
  version = "0.9.2.dev3";
  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "ZerataX";
    repo = pname;
    rev = "1dd1c7c48acf6c3be91d590d8740d849e8c7dfa8";
    sha256 = "70413bf000719ad6924d91ce4c63496b0e56f69f8ac22fe6a21be15c9825a47f";
  };

  postPatch = ''
    sed -i -e '/alembic>/d' setup.py
    sed -i -e '/parameterized>/d' setup.py
    sed -i -e 's/~=/>=/' setup.py
    rm -rf tests/
  '';

  propagatedBuildInputs = [
    appdirs
    flask
    flask-babel
    flask-cors
    flask-httpauth
    flask-limiter
    flask_sqlalchemy
    jsonschema
    python-dateutil
    pyyaml
    requests
    waitress
    wtforms
    parameterized
  ] ++ dbDrivers;

  # checkInputs = [
  #   flake8
  #   parameterized
  # ];

  # `alembic` (a database migration tool) is only needed for the initial setup,
  # and not needed during the actual runtime. However `alembic` requires `matrix-registration`
  # in its environment to create a database schema from all models.
  #
  # Hence we need to patch away `alembic` from `matrix-registration` and create an `alembic`
  # which has `matrix-registration` in its environment.
  passthru.alembic = alembic.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ dbDrivers ++ [
      pkgs.matrix-registration
    ];
  });

  meta = with lib; {
    homepage = "https://github.com/ZerataX/matrix-registration/";
    description = "a token based matrix registration api";
    # license = licenses.mit;
    # maintainers = with maintainers; [ zeratax ];
  };
}
