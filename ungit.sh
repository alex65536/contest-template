#!/bin/bash

# Makes a normal contest template from the GitHub's version of it

rm -rf .git &&
find . -name .gitignore -delete &&
rm -f README.md &&
test -f LICENSE &&
(
    echo "Here is the license for the contest template."
    echo "It can be found at https://github.com/alex65536/contest-template."
    echo
    cat LICENSE
) > LICENSE.template &&
rm -f LICENSE &&
rm -f ungit.sh
