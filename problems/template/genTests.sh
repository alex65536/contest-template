#!/bin/bash

function runPretestGen {

tcat <<<"2 2"
tcat <<<"3 5"

}


function runTestGen {

tcat <<<"100 100"
tcat <<<"200 200"
tcat <<<"-1 -2"
tcat <<<"-42 42"

}
