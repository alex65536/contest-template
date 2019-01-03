#!/usr/bin/env python3

import os
import sys
import json

in_fmt = '%02d'
out_fmt = '%02d.a'

def get_test(path, test_num, test_fmt):
    return os.path.join(path, 'tests', test_fmt % test_num)

def testerize(path):
    src_prob = json.loads(open(os.path.join(path, 'problem.json'), 'r').read())['problem']
    dst_prob = {}
    dst_prob['InputFile'] = 'stdin' if src_prob['input'] == '' else src_prob['input']
    dst_prob['OutputFile'] = 'stdout' if src_prob['output'] == '' else src_prob['output']
    dst_prob['TimeLimit'] = int(src_prob['timeLimit'] * 1000)
    dst_prob['MemoryLimit'] = int(src_prob['memoryLimit'] * 1024)
    dst_prob['StopAfterFirstFail'] = False
    if os.path.exists(os.path.join(path, 'checker.cpp')):
        dst_prob['Checker'] = {
            'Type': 'TTextChecker',
            'Value': {
                'CheckerFileName': 'checker.exe',
                'ParamsPolicy': 'secpInOutAns'
            }
        }
    else:
        dst_prob['Checker'] = {
            'Type': 'TFileCompareChecker',
            'Value': {
                'StripSpaces': True
            }
        }
    dst_prob['Version'] = {
        'Build': 129,
        'Major': 1,
        'Minor': 2,
        'Release': 3,
        'Tag': ''
    }
    dst_prob['TestList'] = []
    test_id = 1
    while os.path.exists(get_test(path, test_id, in_fmt)) or os.path.exists(get_test(path,test_id, out_fmt)):
        cur_test = {
            'Cost': 1.0,
        }
        cur_test['InputFile'] = in_fmt % test_id
        cur_test['OutputFile'] = out_fmt % test_id
        dst_prob['TestList'] += [cur_test]
        test_id += 1
    test_cost = 0 if test_id == 1 else 100.0 / (test_id - 1)
    for i in range(test_id - 1):
        dst_prob['TestList'][i]['Cost'] = test_cost
    open(os.path.join(path, 'tests', 'props.json'), 'w').write(json.dumps(dst_prob, indent=2))

def main(args):
    if len(args) <= 1:
        print('Usage: ./testerize.py <problem directory>')
        return 1
    testerize(args[1])
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
