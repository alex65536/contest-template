#!/bin/bash

function runPretestGen {

makeTest <<<"2 2"
makeTest <<<"3 5"

}

function runTestGen {

makeTest <<<"100 100"
makeTest <<<"200 200"
makeTest <<<"-1 -2"
makeTest <<<"-42 42"

}
