#!/usr/bin/env python3
import sys
import json
from os import path

if len(sys.argv) < 2:
    sys.stderr.write("Usage: {} PROBLEM\n".format(sys.argv[0]))
    sys.exit(1)

problem = sys.argv[1]

obj = None
tl = "??? секунд"
ml = "??? мегабайт"
infile = "???.in"
outfile = "???.out"

try:
    obj = json.loads(open(path.join("..", "problems",
                                    problem, "problem.json"), 'r').read())
except FileNotFoundError:
    pass

if obj:
    tl_sec = obj["problem"]["timeLimit"]
    tl_sec_int = round(tl_sec)
    if abs(tl_sec_int - tl_sec) < 1e-12:
        word = "секунд"
        if 10 <= tl_sec_int % 100 <= 19:
            word = "секунд"
        elif tl_sec_int % 10 == 1:
            word = "секунда"
        elif tl_sec_int % 10 in {2, 3, 4}:
            word = "секунды"
        tl = format("{} {}".format(tl_sec_int, word))
    else:
        tl = format("{:.3g} секунды".format(tl_sec))

    ml_mb = int(obj["problem"]["memoryLimit"])
    word = "мегабайта"
    if 10 <= ml_mb % 100 <= 19 or ml_mb % 10 in {0, 5, 6, 7, 8, 9}:
        word = "мегабайт"
    elif ml_mb % 10 == 1:
        word = "мегабайт"
    ml = str(ml_mb) + ' ' + word

    infile = obj["problem"]["input"]
    if not infile:
        infile = "стандартный ввод"
    outfile = obj["problem"]["output"]
    if not outfile:
        outfile = "стандартный ввод"

print("\\def\\ProblemTimeLimit{{{}}}".format(tl))
print("\\def\\ProblemMemoryLimit{{{}}}".format(ml))
print("\\def\\ProblemInputFile{{{}}}".format(infile))
print("\\def\\ProblemOutputFile{{{}}}".format(outfile))
print("\\input{{{}.tex}}".format(problem))
print()
