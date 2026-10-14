"""Cross-read MoonIon's actual text and binary output with Amazon's ion-python.
Install test-only dependency: python -m pip install amazon.ion==0.13.0
Run from the repository root: python tests/verify_interop.py --target wasm-gc
"""
import argparse
import json
import subprocess
from pathlib import Path
from amazon.ion import simpleion
from amazon.ion.equivalence import ion_equals

parser = argparse.ArgumentParser()
parser.add_argument('--target', choices=['wasm-gc', 'js', 'native'], default='wasm-gc')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
fixtures = json.loads((root / 'tests/interop-fixtures.json').read_text(encoding='utf-8'))
result = subprocess.run(['moon', 'run', 'examples/interop', '--target', args.target],
                        cwd=str(root), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                        encoding='utf-8', check=True)
count = 0
for line in result.stdout.splitlines():
    key, hex_data, text = line.split('|', 2)
    if hex_data == 'ERROR':
        raise AssertionError('%s: %s' % (key, text))
    binary_value = simpleion.loads(bytes.fromhex(hex_data))
    text_value = simpleion.loads(text)
    if not ion_equals(binary_value, text_value):
        raise AssertionError('%s: binary/text type or value mismatch' % key)
    if key.isdigit():
        expected = simpleion.loads(fixtures[int(key)]['text'])
        if not ion_equals(expected, binary_value):
            raise AssertionError('%s: official input/output mismatch' % key)
    count += 1
assert count == len(fixtures) + 3, 'Incomplete example output'
print('%s: %d cases, official reader accepted both MoonIon binary and text; values/types matched.' % (args.target, count))
