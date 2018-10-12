#!/usr/bin/env python3
#   A postprocessor for Yandex.Contest that can read subtasks info from
# problem.json.
#   Made for using with https://github.com/alex65536/contest-template.
#
#   This script is licensed under MIT license:
#
#   Copyright (c) 2018 Alexander Kernozhitsky
#
#   Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

import json
from sys import stdin, stdout, stderr
import re
import traceback


# Verbose levels
# 0 - no stderr (except warnings)
# 1 - print total score only
# 2 - print report on tests (byTest) and on subtasks (subtask)
# 3 - print failure reason on subtasks
# 4 - print entire log on subtasks
def process(verbose=3):
    testlog = json.loads(stdin.read())

    problem = json.loads(open('problem.json', 'r').read())['problem']

    verdicts = [
        test['verdict'] for test in testlog['tests']
        if test['testsetName'] != 'samples']

    test_results = [v == 'ok' for v in verdicts]

    score = 0
    max_score = 0
    score_type = problem['scoreType']

    if score_type == 'byTest':
        cost = problem['cost']
        testid = 0
        for res in test_results:
            testid += 1
            add_score = cost if res else 0
            if verbose > 1:
                stderr.write('test {}: {}/{} points\n'.format(
                    testid, add_score, cost))
            score += add_score
            max_score += cost
    elif score_type == 'subtask':
        testid = 0
        groupid = 0
        for subtask in problem['subtasks']:
            accepted = True
            fail_reason = ''
            for i in range(subtask[1]):
                if verbose > 3:
                    stdout.write(' - test {}: {}\n'.format(
                        testid+1, verdicts[testid]))
                if not test_results[testid]:
                    accepted = False
                    if fail_reason == '':
                        fail_reason = ' - test {}: {}\n'.format(
                            testid+1, verdicts[testid])
                testid += 1
            cost = subtask[0]
            add_score = cost if accepted else 0
            if verbose > 1:
                groupid += 1
                stderr.write('subtask {}: {}/{} points\n'.format(
                    groupid, add_score, cost))
                if verbose == 3:
                    if accepted:
                        stderr.write(' - passed\n')
                    else:
                        stderr.write(fail_reason)
            score += add_score
            max_score += cost
        if testid != len(verdicts):
            stderr.write('WARNING: {} tests processed, but {} tests exist\n'
                         .format(testid, len(verdicts)))
    else:
        raise Exception('Unknown scoring type')

    if verbose > 0:
        stderr.write('total score: {}/{} points'.format(score, max_score))

    return score


try:
    stdout.write('{}\n'.format(process()))
except:
    stdout.write('-42\n')
    traceback.print_exc(file=stderr)
