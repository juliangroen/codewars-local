#!/bin/bash

dockerfile=$(cat <<-"HEREDOC"
# syntax=docker/dockerfile:1.3-labs
FROM python:slim

RUN mkdir /app && mkdir /app/src

WORKDIR /app

COPY <<-"EOF" /app/codewars-local.py
import os
class Test:
    def __init__(self):
        pass
    def assert_equals(self, a, b, msg = ""):
        message = f": {msg}" if msg != "" else {msg}
        if a == b:
            print(f'✅ Test Passed')
            return True
        else:
            print(f'❌ {a} should equal {b}{message}')
            return False
test = Test()
pwd = os.path.dirname(__file__)
exec(open(f"{pwd}/src/tests.py").read())
EOF

COPY <<-"EOF" /app/src/tests.py
print("test")
EOF

CMD ["python", "codewars-local.py"]
HEREDOC
)

function build_image() {
  echo "${dockerfile}" | DOCKER_BUILDKIT=1 docker build -t codewars-local -
}
  
function run_tests() {
  docker run --rm -v "${PWD}"/src:/app/src codewars-local
}

help_msg=$(cat <<-"EOF"
Usage: cwl.sh <command>

Commands:

  build - Builds the "codewars-local" image
  test  - Runs the tests located in $PWD/src/tests.py via the "codewars-local" container

Required Files:

  This script expects a "src" directory in the present working directory. The expected
  files inside the "src" directory are as follows:

    "solution.py" - Contains the code to solve the code kata.
    "tests.py"    - Contains the basic tests from the code kata.

Setup:

  The only required code is contained in the "tests.py" file. You will need to include
  "from src.solution import *" at the top of the file before any sample tests. This is to
  ensure that the function created in the "solution.py" file is available for the
  sample tests to call.

EOF
)

case "$1" in
  build) build_image
  ;;
  test) run_tests
  ;;
  *) echo "${help_msg}"
  ;;
esac

